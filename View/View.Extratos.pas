unit View.Extratos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  System.Actions, FMX.ActnList, FMX.ListBox, FMX.Edit, FMX.EditBox, FMX.NumberBox, System.DateUtils, FMX.ComboEdit,
  Controller.RESTExtratos, Data.DB, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.Grid,
  Data.Bind.DBScope, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
  Tview_Extratos = class(TForm)
    layoutPadrao: TLayout;
    actionListExtratos: TActionList;
    actionProcessar: TAction;
    layoutFiltro: TLayout;
    labelAno: TLabel;
    labelMes: TLabel;
    labelQuinzena: TLabel;
    stringGridExtrato: TStringGrid;
    columnEntregas: TColumn;
    columnVerba: TColumn;
    columnProducao: TColumn;
    layoutFooter: TLayout;
    labelDebitos: TLabel;
    labelCreditos: TLabel;
    labelExtravios: TLabel;
    labelTotal: TLabel;
    labelValorDebitos: TLabel;
    labelValorCreditos: TLabel;
    labelValorExtravios: TLabel;
    labelValorTotal: TLabel;
    comboBoxAno: TComboBox;
    comboBoxMes: TComboBox;
    comboBoxQuinzena: TComboBox;
    imageSearch: TImage;
    layoutTitle: TLayout;
    rectangleTitle: TRectangle;
    imageExit: TImage;
    labelTitle: TLabel;
    listViewExtrato: TListView;
    procedure imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure FormCreate(Sender: TObject);
    procedure rectangleFilterMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure rectangleFilterMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure actionProcessarExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imageSearchMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
    procedure SetupYears;
    procedure ProcessExtrato(sEntregador, sAno, sMes, sQuinzena: String);
    procedure LimpaTela;
  public
    { Public declarations }
  end;

var
  view_Extratos: Tview_Extratos;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}

uses DM.Main, Common.Params;

procedure Tview_Extratos.actionProcessarExecute(Sender: TObject);
begin
  LimpaTela;
  ProcessExtrato( Common.Params.paramCodeDelivery.ToString, comboBoxAno.Items[comboBoxAno.ItemIndex],comboBoxMes.ItemIndex.ToString, comboBoxQuinzena.ItemIndex.ToString);
end;

procedure Tview_Extratos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LimpaTela;
end;

procedure Tview_Extratos.FormCreate(Sender: TObject);
begin
  SetupYears;
end;

procedure Tview_Extratos.imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Close;
end;

procedure Tview_Extratos.imageSearchMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  actionProcessarExecute(Sender);
end;

procedure Tview_Extratos.LimpaTela;
begin
  labelValorDebitos.Text := '0,00';
  labelValorCreditos.Text := '0,00';
  labelValorExtravios.Text := '0,00';
  labelValorTotal.Text := '0,00';
  stringGridExtrato.RowCount := 0;
end;

procedure Tview_Extratos.ProcessExtrato(sEntregador, sAno, sMes, sQuinzena: String);
var
  FExtrato: TRESTExtratosController;
  i: Integer;
  dCreditos, dDebitos, dExtravios, dTotal: Double;
  itemList: TListViewItem;
begin
  try
    FExtrato := TRESTExtratosController.Create;
    if FExtrato.SearchExtrato(sEntregador, sAno, sMes, sQuinzena) then
    begin
      DM_Main.memTableExtrato.First;
      i := 0;
      stringGridExtrato.RowCount := DM_Main.memTableExtrato.RecordCount;
      dCreditos := 0;
      dDebitos := 0;
      dExtravios := 0;
      dTotal := 0;
      listViewExtrato.Items.Clear;
      listViewExtrato.BeginUpdate;
      while not DM_Main.memTableExtrato.Eof do
      begin
        stringGridExtrato.Cells[0,i] := FormatFloat('#,##;(#,##)', StrToIntDef(DM_Main.memTableExtratoqtd_entregas.AsString, 0));
        stringGridExtrato.Cells[1,i] := FormatFloat('#,##0.00;(#,##0.00)', StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_verba.AsString, '.', ',', [rfReplaceAll]),0));
        stringGridExtrato.Cells[2,i] := FormatFloat('#,##0.00;(#,##0.00)', StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_producao.AsString, '.', ',', [rfReplaceAll]),0));
        dCreditos := dCreditos + StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_creditos.AsString, '.', ',', [rfReplaceAll]),0);
        dDebitos := dDebitos + StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_debitos.AsString, '.', ',', [rfReplaceAll]),0);
        dExtravios := dExtravios + StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_extravios.AsString, '.', ',', [rfReplaceAll]),0);
        dTotal := dTotal + StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_total_expressa.AsString, '.', ',', [rfReplaceAll]),0);
        itemList := listViewExtrato.Items.Add;
        itemList.IndexTitle := 'Qtde: ' + FormatFloat('#,##0;(#,##0)', StrToIntDef(DM_Main.memTableExtratoqtd_entregas.AsString, 0));
        itemList.Detail := 'Verba: ' + FormatFloat('#,##0.00;(#,##0.00)', StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_verba.AsString, '.', ',', [rfReplaceAll]),0));;
        itemList.Text := 'Total: ' + FormatFloat('#,##0.00;(#,##0.00)', StrToFloatDef(StringReplace(DM_Main.memTableExtratoval_producao.AsString, '.', ',', [rfReplaceAll]),0));
        Inc(i, 1);
        DM_Main.memTableExtrato.Next;
      end;
      labelValorDebitos.Text := FormatFloat('#,##0.00;-#,##0.00', dDebitos);
      labelValorCreditos.Text := FormatFloat('#,##0.00;-#,##0.00', dCreditos);
      labelValorExtravios.Text := FormatFloat('#,##0.00;-#,##0.00', dExtravios);
      labelValorTotal.Text := FormatFloat('#,##0.00;-#,##0.00', dTotal);
    end;
  finally
    DM_Main.memTableExtrato.Close;
    FExtrato.Free;
  end;
end;

procedure Tview_Extratos.rectangleFilterMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 0.8;
end;

procedure Tview_Extratos.rectangleFilterMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 1;
  actionProcessarExecute(Sender);
end;

procedure Tview_Extratos.SetupYears;
var
  iAnoMax, iAnoMin,i : Integer;
begin
  iAnoMin := YearOf(Now) - 1;
  iAnoMax := YearOf(Now) + 1;
  comboBoxAno.Items.Clear;
  for i := iAnoMin to iAnoMax do
  begin
    comboBoxAno.Items.Add(i.ToString)
  end;
  if comboBoxAno.Items.Count > 0 then
  begin
    comboBoxAno.ItemIndex := 1;
  end;
end;

end.
