unit View.Extratos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  System.Actions, FMX.ActnList, FMX.ListBox, FMX.Edit, FMX.EditBox, FMX.NumberBox, System.DateUtils, FMX.ComboEdit,
  Data.DB, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.Grid,
  Data.Bind.DBScope, Controller.RESTExtravios, Controller.RESTEntregas, Controller.RESTLancamentos;

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
    layoutFooter: TLayout;
    labelTotal: TLabel;
    labelValorTotal: TLabel;
    comboBoxAno: TComboBox;
    comboBoxMes: TComboBox;
    comboBoxQuinzena: TComboBox;
    imageSearch: TImage;
    layoutTitle: TLayout;
    rectangleTitle: TRectangle;
    imageExit: TImage;
    labelTitle: TLabel;
    stringColumnDescricao: TStringColumn;
    stringColumnValor: TStringColumn;
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
    procedure ProcessExtrato(sentregador, sdataini, sdatafim: String);
    procedure ProcessaExtravios(sEntregador, sExtratos: String);
    procedure ProcessaLancamentos(sEntregador, sdata,sExtratos: String);
    procedure LimpaTela;
    procedure MontaPeriodo(iAno, iMes, iQuinzena: Integer);
  public
    { Public declarations }
  end;

var
  view_Extratos: Tview_Extratos;
  dtDataInicial : TDate;
  dtDataFinal : TDate;
  dTotal: Double;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}

uses DM.Main, Common.Params;

procedure Tview_Extratos.actionProcessarExecute(Sender: TObject);
begin
  LimpaTela;
  MontaPeriodo(StrToInt(comboBoxAno.Items[comboBoxAno.ItemIndex]), comboBoxMes.ItemIndex, comboBoxQuinzena.ItemIndex);
  ProcessExtrato(Common.Params.paramCodeDelivery.ToString, FormatDateTime('yyyy-mm-dd', dtDataInicial),
  FormatDateTime('yyyy-mm-dd', dtDataFinal));
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
  labelValorTotal.Text := '0,00';
  stringGridExtrato.RowCount := 0;
end;

procedure Tview_Extratos.MontaPeriodo(iAno, iMes, iQuinzena: Integer);
var
  iDiaInicio, iDiaFinal, iMesData, iAnoData: Integer;
  sData: String;
  datData, datBase: TDate;
begin
  iAnoData := iAno;
  if iQuinzena = 1 then
  begin
    iDiaInicio := 26;
    iDiaFinal := 10;
  end
  else if iQuinzena = 2 then
  begin
    iDiaInicio := 11;
    iDiaFinal := 25;
  end
  else if iQuinzena = 3 then
  begin
    iDiaInicio := 1;
    iDiaFinal := 15;
  end
  else if iQuinzena = 4 then
  begin
    iDiaInicio := 16;
    sData := '01/' + FormatFloat('00', iMes) + '/' + IntToStr(iAnoData);
    iDiaFinal := DaysInMonth(StrToDate(sData));
  end;
  if iDiaInicio > iDiaFinal then
  begin
    if iMes = 1 then
    begin
      iMesData := 12;
      iAnoData := iAnoData - 1;
      sData := FormatFloat('00', iDiaInicio) + '/' + FormatFloat('00', iMesData) + '/' + FormatFloat('0000', iAnoData);
    end
    else
    begin
      iMesData := iMes - 1;
      iAnoData := iAno;
      sData := FormatFloat('00', iDiaInicio) + '/' + FormatFloat('00', iMesData) + '/' + FormatFloat('0000', iAnoData);
    end;
    dtDataInicial := StrToDate(sData);
    iMesData := iMes;
    iAnoData := iAno;
    sData := FormatFloat('00', iDiaFinal) + '/' + FormatFloat('00', iMesData) + '/' + FormatFloat('0000', iAnoData);
    dtDataFinal := StrToDate(sData);
  end
  else
  begin
    iMesData := iMes;
    iAnoData := iAno;
    sData := FormatFloat('00', iDiaInicio) + '/' + FormatFloat('00', iMesData) + '/' + FormatFloat('0000', iAnoData);
    dtDataInicial := StrToDate(sData);
    iMesData := iMes;
    iAnoData := iAno;
    if iDiaFinal = 31 then
    begin
      iDiaFinal := DaysInMonth(StrToDate(sData));
    end;
    sData := FormatFloat('00', iDiaFinal) + '/' + FormatFloat('00', iMesData) + '/' + FormatFloat('0000', iAnoData);
    dtDataFinal := StrToDate(sData);
  end;
end;

procedure Tview_Extratos.ProcessaExtravios(sEntregador, sExtratos: String);
var
  FExtravios: TRESTExtraviossController;
  i: Integer;
  dValor : Double;
  sDescricao: String;
begin
  try
    FExtravios := TRESTExtraviossController.Create;
    if FExtravios.SearchExtraviosEntregador(sentregador) then
    begin
      DM_Main.memTableExtravios.First;
      i := Pred(stringGridExtrato.RowCount);
      sExtratos := '';
      if not DM_Main.memTableExtravios.IsEmpty then
      begin
        stringGridExtrato.RowCount := stringGridExtrato.RowCount + DM_Main.memTableExtravios.RecordCount;
      end;
      while not DM_Main.memTableExtravios.Eof do
      begin
        sDescricao := '';
        dValor := 0 - StrToFloatDef(StringReplace(DM_Main.memTableExtraviosval_total.AsString, '.', ',', [rfReplaceAll]),0);
        sDescricao := 'Extravio ' + DM_Main.memTableExtraviosdes_extravio.AsString + #13 + ' NN/Remessa ' +
        DM_Main.memTableExtraviosnum_nossonumero.AsString;
        if dValor < 0 then
        begin
          stringGridExtrato.Cells[0,i] := sDescricao;
          stringGridExtrato.Cells[1,i] := FormatFloat('#,##0.00;-#,##0.00', dValor);
          Inc(i, 1);
          dTotal := dTotal + dValor;
        end;
        DM_Main.memTableExtravios.Next;
      end;
    end;
    sExtratos := Common.Params.paramNumeroExtrato;
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
          sDescricao := 'Extravio ' + DM_Main.memTableExtraviosdes_extravio.AsString + #13 + ' NN/Remessa ' +
          DM_Main.memTableExtraviosnum_nossonumero.AsString;
          if dValor < 0 then
          begin
            stringGridExtrato.Cells[0,i] := sDescricao;
            stringGridExtrato.Cells[1,i] := FormatFloat('#,##0.00;-#,##0.00', dValor);
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

procedure Tview_Extratos.ProcessaLancamentos(sEntregador, sdata, sExtratos: String);
var
  FLancamentos: TRESTLancamentosController;
  i: Integer;
  dValor : Double;
  sDescricao: String;
begin
  try
    FLancamentos := TRESTLancamentosController.Create;
    if FLancamentos.SearchLancamentosEntregador(sentregador, sdata) then
    begin
      DM_Main.memTableLancamentos.First;
      i := Pred(stringGridExtrato.RowCount);
      sExtratos := '';
      if not DM_Main.memTableLancamentos.IsEmpty then
      begin
        stringGridExtrato.RowCount := stringGridExtrato.RowCount + DM_Main.memTableLancamentos.RecordCount;
      end;
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
          stringGridExtrato.Cells[0,i] := sDescricao;
          stringGridExtrato.Cells[1,i] := FormatFloat('#,##0.00;-#,##0.00', dValor);
          Inc(i, 1);
          dTotal := dTotal + dValor;
        end;
        DM_Main.memTableLancamentos.Next;
      end;
    end;
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
            stringGridExtrato.Cells[0,i] := sDescricao;
            stringGridExtrato.Cells[1,i] := FormatFloat('#,##0.00;-#,##0.00', dValor);
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

procedure Tview_Extratos.ProcessExtrato(sentregador, sdataini, sdatafim: String);
var
  FEntregas: TRESTEntregassController;
  i: Integer;
  iEntregas : Integer;
  dVerba, dProducao: Double;
  sDescricao: String;
  sExtratos: String;
  sData: String;
begin
  try
    FEntregas := TRESTEntregassController.Create;
    if FEntregas.SearchEntregas(sentregador, sdataini, sdatafim) then
    begin
      DM_Main.memTableEntregas.First;
      i := 0;
      sExtratos := '';
      stringGridExtrato.RowCount := DM_Main.memTableEntregas.RecordCount;
      dProducao := 0;
      dTotal := 0;
      while not DM_Main.memTableEntregas.Eof do
      begin
        sDescricao := '';
        dVerba := StrToFloatDef(StringReplace(DM_Main.memTableEntregasval_verba.AsString, '.', ',', [rfReplaceAll]),0);
        iEntregas := StrToIntDef(DM_Main.memTableEntregasqtd_entregas.AsString, 0);
        sDescricao := FormatFloat('#,##0;(#,##0)', iEntregas) + ' entregas a ';
        sDescricao := sDescricao + FormatFloat('R$ #,##0.00;(R$ #,##0.00)', dVerba);
        dProducao := dVerba * iEntregas;
        stringGridExtrato.Cells[0,i] := sDescricao;
        stringGridExtrato.Cells[1,i] := FormatFloat('#,##0.00;(#,##0.00)', dProducao);
        dTotal := dTotal + dProducao;
        Inc(i, 1);
        if DM_Main.memTableEntregasnum_extrato.Text.Length > 0 then
        begin
          if sExtratos.Length = 0 then
          begin
            sExtratos := DM_Main.memTableEntregasnum_extrato.Text;;
          end;

        end;
        DM_Main.memTableEntregas.Next;
      end;
      if not sExtratos.IsEmpty then
      begin
        Common.Params.paramNumeroExtrato := sExtratos;
      end;
      sData := FormatDateTime('yyyy-mm-dd', dtDataFinal);
      ProcessaExtravios(Common.Params.paramCodeDelivery.ToString, sExtratos);
      ProcessaLancamentos(Common.Params.paramCodigoCadastro.ToString, sdata, sExtratos);

      labelValorTotal.Text := FormatFloat('#,##0.00;-#,##0.00', dTotal);

    end;
  finally
    DM_Main.memTableEntregas.Close;
    FEntregas.Free;
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
