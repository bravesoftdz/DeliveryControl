unit View.EntregasDia;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  System.Actions, FMX.ActnList, FMX.ListBox, FMX.Edit, FMX.EditBox, FMX.NumberBox, System.DateUtils, FMX.ComboEdit,
  Data.DB, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.Grid,
  Data.Bind.DBScope, Controller.RESTExtravios, Controller.RESTEntregas, Controller.RESTLancamentos, Controller.RESTExtratos,
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
    procedure imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure rectangleFilterMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure rectangleFilterMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure actionProcessarExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imageSearchMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
    procedure ProcessExtrato(sentregador, sdataini, sdatafim: String);
    procedure ListaExtrato(sentregador, sdataini, sdatafim: String);
    procedure LimpaTela;
  public
    { Public declarations }
  end;

var
  view_EntregasDia: Tview_EntregasDia;
  dtDataInicial : TDate;
  dtDataFinal : TDate;
  iTotalCliente : integer;
  iTotalDia : Integer;
  iTotalGeral: Integer;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}

uses DM.Main, Common.Params;

procedure Tview_EntregasDia.actionProcessarExecute(Sender: TObject);
begin
  if DaysBetween(dateEditInicial.Date,dateEditFinal.Date) > 16 then
  begin
    ShowMessage('Período não pode ser maior que 16 dias.');
  end;
end;

procedure Tview_EntregasDia.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LimpaTela;
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

procedure Tview_EntregasDia.ListaExtrato(sentregador, sdataini, sdatafim: String);
var
  FExtratos: TRESTExtratosController;
  i: Integer;
  iEntregas : Integer;
  dVerba, dProducao: Double;
  sDescricao, sQuantidade, sCliente: String;
  sExtratos: String;
  sData: String;
begin
  try
    FExtratos := TRESTExtratosController.Create;
    if FExtratos.SearchExtrato(sentregador, sdataini, sdatafim) then
    begin
      DM_Main.memTableExtrato.First;
      i := 0;
      sExtratos := '';
      stringGridExtrato.RowCount := DM_Main.memTableExtrato.RecordCount;
      dProducao := 0;
      dTotal := 0;
      while not DM_Main.memTableExtrato.Eof do
      begin
        sDescricao := '';
        sQuantidade := '';
        sCliente := '';
        if Trim(DM_Main.memTableExtratocod_cliente.AsString) = '1' then
        begin
          sCliente := 'TFO';
        end
        else if Trim(DM_Main.memTableExtratocod_cliente.AsString) = '4' then
        begin
          sCliente := 'DIRECT';
        end
        else if Trim(DM_Main.memTableExtratocod_cliente.AsString) = '5' then
        begin
          sCliente := 'RODOÊ';
        end;
        dVerba := StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_verba.AsString, '.', ',', [rfReplaceAll]),0);
        iEntregas := StrToIntDef(DM_Main.memTableExtratoqtd_entregas.AsString, 0);
        sQuantidade := FormatFloat('#,##0;(#,##0)', iEntregas);
        sDescricao := 'Entregas/Coletas ' + sCliente;
        dProducao := StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_producao.AsString, '.', ',', [rfReplaceAll]),0);
        stringGridExtrato.Cells[0,i] := sQuantidade;
        stringGridExtrato.Cells[1,i] := sDescricao;
        stringGridExtrato.Cells[2,i] := FormatFloat('#,##0.00;(#,##0.00)', dVerba);
        stringGridExtrato.Cells[3,i] := FormatFloat('#,##0.00;(#,##0.00)', dProducao);
        dTotal := dTotal + dProducao;
        Inc(i, 1);
        if DM_Main.memTableExtratonum_extrato.Text.Length > 0 then
        begin
          if sExtratos.Length = 0 then
          begin
            sExtratos := DM_Main.memTableExtratonum_extrato.Text;
          end
          else
          begin
            if Pos(DM_Main.memTableExtratonum_extrato.Text,sExtratos) = 0 then
            begin
              if sExtratos.Length > 0 then
              begin
                sExtratos := sExtratos + ',';
              end;
              sExtratos := sExtratos +  DM_Main.memTableExtratonum_extrato.Text;
            end;
          end;
        end;
        DM_Main.memTableExtrato.Next;
      end;
      sData := FormatDateTime('yyyy-mm-dd', dtDataFinal);
      ProcessaExtravios('', sExtratos);
      ProcessaLancamentos('', sdata, sExtratos);
      labelValorTotal.Text := FormatFloat('#,##0.00;-#,##0.00', dTotal);
    end;
  finally
    DM_Main.memTableExtrato.Close;
    FExtratos.Free;
  end;
end;

procedure Tview_EntregasDia.MontaPeriodo(iAno, iMes, iDia: Integer);
var
  iDiaInicio, iDiaFinal, iMesInicio, iMesFinal, iAnoInicio, iAnoFinal, iMesData, iAnoData: Integer;
  sData: String;
  datData, datBase: TDate;
begin
  iAnoData := iAno;
  datData := StrToDate(iDia.ToString +'/'+iMes.ToString+'/'+iAno.ToString);
  datBase := IncDay(datData - 45);
  iMesInicio := MonthOf(datBase);
  iAnoInicio := YearOf(datBase);
  datBase := IncDAy(datData - 30);
  iMesFinal := MonthOf(datBase);
  iAnoFinal := YearOf(datBase);
  if iDia = 10 then
  begin
    iDiaInicio := 26;
    iDiaFinal := 10;
  end
  else if iDia = 25 then
  begin
    iDiaInicio := 11;
    iDiaFinal := 25;
  end
  else if iDia = 15 then
  begin
    iDiaInicio := 1;
    iDiaFinal := 15;
  end
  else if iDia = 31 then
  begin
    iDiaInicio := 16;
    sData := '01/' + FormatFloat('00', iMes) + '/' + IntToStr(iAnoData);
    iDiaFinal := DaysInMonth(StrToDate(sData));
  end;
  sData := FormatFloat('00', iDiaInicio) + '/' + FormatFloat('00', iMesInicio) + '/' + FormatFloat('0000', iAnoInicio);
  dtDataInicial := StrToDate(sData);
  sData := FormatFloat('00', iDiaFinal) + '/' + FormatFloat('00', iMesFinal) + '/' + FormatFloat('0000', iAnoFinal);
  dtDataFinal := StrToDate(sData);
end;

procedure Tview_EntregasDia.ProcessaExtravios(sEntregador, sExtratos: String);
var
  FExtravios: TRESTExtraviossController;
  i: Integer;
  dValor : Double;
  sDescricao: String;
begin
  try
    FExtravios := TRESTExtraviossController.Create;
    if not sExtratos.IsEmpty then
    begin
      DM_Main.memTableExtravios.Close;
      if FExtravios.SearchExtraviosExtrato(sExtratos) then
      begin
        DM_Main.memTableExtravios.First;
        i := Pred(stringGridExtrato.RowCount);
        if not DM_Main.memTableExtravios.IsEmpty then
        begin
          stringGridExtrato.RowCount := stringGridExtrato.RowCount + DM_Main.memTableExtravios.RecordCount;
        end;
        while not DM_Main.memTableExtravios.Eof do
        begin
          sDescricao := '';
          dValor := 0 - StrToFloatDef(StringReplace(DM_Main.memTableExtraviosval_total.AsString, '.', ',', [rfReplaceAll]),0);
          sDescricao := 'Extravio/Multa ' + DM_Main.memTableExtraviosdes_extravio.AsString + #13 + ' NN/Remessa ' +
          DM_Main.memTableExtraviosnum_nossonumero.AsString;
          if dValor < 0 then
          begin
            stringGridExtrato.Cells[0,i] := '1';
            stringGridExtrato.Cells[1,i] := sDescricao;
            stringGridExtrato.Cells[2,i] := '';
            stringGridExtrato.Cells[3,i] := FormatFloat('#,##0.00;-#,##0.00', dValor);
          end;
          Inc(i, 1);
          dTotal := dTotal + dValor;
          DM_Main.memTableExtravios.Next;
        end;
      end;
    end;
  finally
    DM_Main.memTableExtravios.Close;
    FExtravios.Free;
  end;
end;

procedure Tview_EntregasDia.ProcessaLancamentos(sEntregador, sdata, sExtratos: String);
var
  FLancamentos: TRESTLancamentosController;
  i: Integer;
  dValor : Double;
  sDescricao: String;
begin
  try
    FLancamentos := TRESTLancamentosController.Create;
    if not sExtratos.IsEmpty then
    begin
      DM_Main.memTableLancamentos.Close;
      if FLancamentos.SearchLancamentosExtrato(sExtratos) then
      begin
        DM_Main.memTableLancamentos.First;
        i := Pred(stringGridExtrato.RowCount);
        if not DM_Main.memTableLancamentos.IsEmpty then
        begin
          stringGridExtrato.RowCount := stringGridExtrato.RowCount + DM_Main.memTableLancamentos.RecordCount;
        end;
        stringGridExtrato.RowCount := stringGridExtrato.RowCount + DM_Main.memTableLancamentos.RecordCount;
        while not DM_Main.memTableLancamentos.Eof do
        begin
          sDescricao := '';
          if DM_Main.memTableLancamentosdes_tipo.AsString = 'DEBITO' then
          begin
            dValor := 0 - StrToFloatDef(StringReplace(DM_Main.memTableLancamentosval_lancamento.AsString, '.', ',', [rfReplaceAll]),0);
          end
          else
          begin
            dValor := StrToFloatDef(StringReplace(DM_Main.memTableLancamentosval_lancamento.AsString, '.', ',', [rfReplaceAll]),0);
          end;
          sDescricao := DM_Main.memTableLancamentosdes_lancamento.AsString;
          if dValor <> 0 then
          begin
            stringGridExtrato.Cells[0,i] := '1';
            stringGridExtrato.Cells[1,i] := sDescricao;
            stringGridExtrato.Cells[2,i] := '';
            stringGridExtrato.Cells[3,i] := FormatFloat('#,##0.00;-#,##0.00', dValor);
            Inc(i, 1);
            dTotal := dTotal + dValor;
          end;
          DM_Main.memTableLancamentos.Next;
        end;
      end;
    end;
  finally
    DM_Main.memTableLancamentos.Close;
    FLancamentos.Free;
  end;

end;

procedure Tview_EntregasDia.ProcessExtrato(sentregador, sdataini, sdatafim: String);
var
  FEntregas: TRESTEntregassController;
  i: Integer;
  iEntregas : Integer;
  dVerba, dProducao: Double;
  sDescricao, sQuantidade, sCliente: String;
  sData: String;
begin
  try
    FEntregas := TRESTEntregassController.Create;
    if FEntregas.SearchEntregas(sentregador, sdataini, sdatafim) then
    begin
      DM_Main.memTableEntregas.First;
      i := 0;
      stringGridExtrato.RowCount := DM_Main.memTableEntregas.RecordCount;
      dProducao := 0;
      dTotal := 0;
      while not DM_Main.memTableEntregas.Eof do
      begin
        sDescricao := '';
        sQuantidade := '';
        sCliente := '';
        if Trim(DM_Main.memTableEntregascod_cliente.AsString) = '1' then
        begin
          sCliente := 'TFO';
        end
        else if Trim(DM_Main.memTableEntregascod_cliente.AsString) = '4' then
        begin
          sCliente := 'DIRECT';
        end
        else if Trim(DM_Main.memTableEntregascod_cliente.AsString) = '5' then
        begin
          sCliente := 'RODOÊ';
        end;
        dVerba := StrToFloatDef(StringReplace(DM_Main.memTableEntregasval_verba.AsString, '.', ',', [rfReplaceAll]),0);
        iEntregas := StrToIntDef(DM_Main.memTableEntregasqtd_entregas.AsString, 0);
        sQuantidade := FormatFloat('#,##0;(#,##0)', iEntregas);
        if DM_Main.memTableEntregasdes_tipo.AsString = 'Loja' then
        begin
          sDescricao := 'Entregas Lojas ' + sCliente;
        end
        else
        begin
          sDescricao := 'Entregas ' + sCliente;
        end;
        dProducao := dVerba * iEntregas;
        stringGridExtrato.Cells[0,i] := sQuantidade;
        stringGridExtrato.Cells[1,i] := sDescricao;
        stringGridExtrato.Cells[2,i] := FormatFloat('#,##0.00;(#,##0.00)', dVerba);
        stringGridExtrato.Cells[3,i] := FormatFloat('#,##0.00;(#,##0.00)', dProducao);
        dTotal := dTotal + dProducao;
        Inc(i, 1);
        DM_Main.memTableEntregas.Next;
      end;
      labelValorTotal.Text := FormatFloat('#,##0.00;-#,##0.00', dTotal);
    end;
  finally
    DM_Main.memTableEntregas.Close;
    FEntregas.Free;
  end;
end;

procedure Tview_EntregasDia.rectangleFilterMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 0.8;
end;

procedure Tview_EntregasDia.rectangleFilterMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 1;
  actionProcessarExecute(Sender);
end;


end.
