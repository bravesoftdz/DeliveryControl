unit View.EntregasDia;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  System.Actions, FMX.ActnList, FMX.ListBox, FMX.Edit, FMX.EditBox, FMX.NumberBox, System.DateUtils, FMX.ComboEdit,
  Data.DB, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.Grid,
  Data.Bind.DBScope, Controller.RESTExtravios, Controller.RESTEntregasDia,
  FMX.DateTimeCtrls;

type
  Tview_EntregasDia = class(TForm)
    layoutPadrao: TLayout;
    actionListExtratos: TActionList;
    actionProcessar: TAction;
    layoutFiltro: TLayout;
    stringGridExtrato: TStringGrid;
    layoutFooter: TLayout;
    imageSearch: TImage;
    layoutTitle: TLayout;
    rectangleTitle: TRectangle;
    imageExit: TImage;
    labelTitle: TLabel;
    labelTitulo: TLabel;
    dateEditInicial: TDateEdit;
    labelInicial: TLabel;
    dateEditFinal: TDateEdit;
    Label1: TLabel;
    stringColumnCliente: TStringColumn;
    stringColumnTipo: TStringColumn;
    dateColumnData: TDateColumn;
    integerColumnQtde: TIntegerColumn;
    integerColumnCodCliente: TIntegerColumn;
    Label2: TLabel;
    rectangleDetalhe: TRectangle;
    labelDetalhe: TLabel;
    actionDetalhar: TAction;
    procedure imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure rectangleFilterMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure actionProcessarExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imageSearchMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure FormShow(Sender: TObject);
    procedure stringGridExtratoCellDblClick(const Column: TColumn; const Row: Integer);
    procedure actionDetalharExecute(Sender: TObject);
    procedure rectangleDetalheMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure rectangleDetalheMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
    procedure ProcessExtrato(sentregador, sdataini, sdatafim: String);
    procedure LimpaTela;
    procedure DetalhaEntregas;
    function ValidaDados(): boolean;
  public
    { Public declarations }
  end;

var
  view_EntregasDia: Tview_EntregasDia;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}

uses DM.Main, Common.Params, View.EntregasDetalhe;

procedure Tview_EntregasDia.actionDetalharExecute(Sender: TObject);
begin
  DetalhaEntregas;
end;

procedure Tview_EntregasDia.actionProcessarExecute(Sender: TObject);
begin
  if not ValidaDados() then Exit;
  ProcessExtrato(Common.Params.paramCodigosEntregadores, FormatDateTime('yyyy-mm-dd', dateEditInicial.Date),
    FormatDateTime('yyyy-mm-dd', dateEditFinal.Date));
end;

procedure Tview_EntregasDia.DetalhaEntregas;
var
  sEntregador, sData, sCliente: String;
  i: Integer;
begin
  if stringGridExtrato.RowCount = 0 then Exit;
  i := stringGridExtrato.Row;
  if not Assigned(view_EntregasDetalhe) then
  begin
    Application.CreateForm(Tview_EntregasDetalhe, view_EntregasDetalhe);
  end;
  sData := FormatDateTime('yyyy-mm-dd', StrToDateDef(stringGridExtrato.Cells[1,i],0));
  view_EntregasDetalhe.sEntregador :=  Common.Params.paramCodigosEntregadores;
  view_EntregasDetalhe.sData := sData;
  view_EntregasDetalhe.sCliente := stringGridExtrato.Cells[4,i];
  view_EntregasDetalhe.Show;
end;

procedure Tview_EntregasDia.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LimpaTela;
end;

procedure Tview_EntregasDia.FormShow(Sender: TObject);
begin
  dateEditInicial.Date := Now;
  dateEditFinal.Date := Now;
end;

procedure Tview_EntregasDia.imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Close;
end;

procedure Tview_EntregasDia.imageSearchMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  actionProcessarExecute(Sender);
end;

procedure Tview_EntregasDia.LimpaTela;
begin
  stringGridExtrato.RowCount := 0;
end;


procedure Tview_EntregasDia.ProcessExtrato(sentregador, sdataini, sdatafim: String);
var
  FEntregas: TRESTEntregasDiaController;
  sDescricao, sQuantidade, sCliente, sCodCliente, sCodClienteOld: String;
  sData: String;
  iTotalCliente, iTotalGeral, i, iEntregas: Integer;
begin
  try
    FEntregas := TRESTEntregasDiaController.Create;
    if FEntregas.SearchEntregas(sentregador, sdataini, sdatafim) then
    begin
      DM_Main.memTableEntregasDia.First;
      iTotalCliente := 0;
      iTotalGeral := 0;
      i := 0;
      iEntregas := 0;
      sCodCliente := '';
      sCodClienteOld := '';
      while not DM_Main.memTableEntregasDia.Eof do
      begin
        sCodCliente := DM_Main.memTableEntregasDiacod_cliente.AsString;
        sData := Copy(DM_Main.memTableEntregasDiadat_baixa.AsString,9,2) + '/' +
                 Copy(DM_Main.memTableEntregasDiadat_baixa.AsString,6,2) + '/' +
                 Copy(DM_Main.memTableEntregasDiadat_baixa.AsString,1,4);
        if sCodClienteOld <> sCodCliente then
        begin
          sCodClienteOld := DM_Main.memTableEntregasDiacod_cliente.AsString;
          if iTotalCliente > 0 then
          begin
            stringGridExtrato.RowCount := (stringGridExtrato.RowCount + 1);
            i := Pred(stringGridExtrato.RowCount);
            stringGridExtrato.Cells[1,i] := 'Tot. Cliente';
            stringGridExtrato.Cells[3,i] := FormatFloat('###,##0;(###,##0)', iTotalCliente);
          end;
          iTotalCliente := 0;
        end;
        sDescricao := '';
        sQuantidade := '';
        sCliente := '';
        if Trim(sCodcliente) = '1' then
        begin
          sCliente := 'TFO';
        end
        else if Trim(sCodcliente) = '4' then
        begin
          sCliente := 'DIRECT';
        end
        else if Trim(sCodcliente) = '5' then
        begin
          sCliente := 'RODO�';
        end;
        iEntregas := StrToIntDef(DM_Main.memTableEntregasDiaqtd_entregas.AsString, 0);
        sQuantidade := FormatFloat('#,##0;(#,##0)', iEntregas);
        if DM_Main.memTableEntregasdes_tipo.AsString = '' then
        begin
          sDescricao := 'ENTREGA';
        end;
        stringGridExtrato.RowCount := (stringGridExtrato.RowCount + 1);
        i := Pred(stringGridExtrato.RowCount);
        stringGridExtrato.Cells[0,i] := sCliente;
        stringGridExtrato.Cells[1,i] := sData;
        stringGridExtrato.Cells[2,i] := sDescricao;
        stringGridExtrato.Cells[3,i] := sQuantidade;
        stringGridExtrato.Cells[4,i] := sCodCliente;
        iTotalCliente := iTotalCliente + iEntregas;
        iTotalGeral := iTotalGeral + iEntregas;
        DM_Main.memTableEntregasDia.Next;
      end;
      if iTotalCliente > 0 then
      begin
        stringGridExtrato.RowCount := (stringGridExtrato.RowCount + 1);
        i := Pred(stringGridExtrato.RowCount);
        stringGridExtrato.Cells[1,i] := 'Tot. Cliente';
        stringGridExtrato.Cells[3,i] := FormatFloat('###,##0;(###,##0)', iTotalCliente);
      end;
      if iTotalGeral > 0 then
      begin
        stringGridExtrato.RowCount := (stringGridExtrato.RowCount + 1);
        i := Pred(stringGridExtrato.RowCount);
        stringGridExtrato.Cells[1,i] := 'Tot. Geral';
        stringGridExtrato.Cells[3,i] := FormatFloat('###,##0;(###,##0)', iTotalGeral);
      end;
      iTotalCliente := 0;
      iTotalGeral := 0;
    end;
  finally
    DM_Main.memTableEntregasDia.Close;
    FEntregas.Free;
  end;
end;

procedure Tview_EntregasDia.rectangleDetalheMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 0.8;
end;

procedure Tview_EntregasDia.rectangleDetalheMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 1;
  actionDetalharExecute(Sender);
end;

procedure Tview_EntregasDia.rectangleFilterMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 0.8;
end;

procedure Tview_EntregasDia.stringGridExtratoCellDblClick(const Column: TColumn; const Row: Integer);
begin
  DetalhaEntregas;
end;

function Tview_EntregasDia.ValidaDados: boolean;
begin
  Result := False;
  if dateEditInicial.Text = '' then
  begin
    ShowMessage('Informe a data inicial do per�odo.');
    Exit;
  end;
  if dateEditFinal.Text = '' then
  begin
    ShowMessage('Informe a data final do per�odo.');
    Exit;
  end;
  if dateEditInicial.Date > dateEditFinal.Date then
  begin
    ShowMessage('Per�odo inv�lido.');
    Exit;
  end;
  if DaysBetween(dateEditInicial.Date,dateEditFinal.Date) > 16 then
  begin
    ShowMessage('Per�odo n�o pode ser maior que 16 dias.');
    Exit;
  end;
  Result := True;
end;

end.
