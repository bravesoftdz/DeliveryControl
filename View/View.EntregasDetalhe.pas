unit View.EntregasDetalhe;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  System.Actions, FMX.ActnList, FMX.ListBox, FMX.Edit, FMX.EditBox, FMX.NumberBox, System.DateUtils, FMX.ComboEdit,
  Data.DB, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, system.StrUtils,
  FMX.Grid, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.Grid,
  Data.Bind.DBScope, Controller.RESTExtravios, Controller.RESTEntregasDetalhe,
  FMX.DateTimeCtrls;

type
  Tview_EntregasDetalhe = class(TForm)
    layoutPadrao: TLayout;
    actionListExtratos: TActionList;
    actionProcessar: TAction;
    layoutFiltro: TLayout;
    stringGridExtrato: TStringGrid;
    layoutFooter: TLayout;
    layoutTitle: TLayout;
    rectangleTitle: TRectangle;
    imageExit: TImage;
    labelTitle: TLabel;
    Label2: TLabel;
    ctringColumnRemessa: TStringColumn;
    floatColumnPeso: TFloatColumn;
    stringColumnTipo: TStringColumn;
    procedure imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessExtrato(sentregador, sdata, scliente: String);
    procedure LimpaTela;
  public
    { Public declarations }
    sEntregador,sData, sCliente: String;
  end;
var
  view_EntregasDetalhe: Tview_EntregasDetalhe;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}

uses DM.Main, Common.Params;

procedure Tview_EntregasDetalhe.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LimpaTela;
end;

procedure Tview_EntregasDetalhe.FormShow(Sender: TObject);
begin
  ProcessExtrato(sEntregador, sData, sCliente);
end;

procedure Tview_EntregasDetalhe.imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Close;
end;

procedure Tview_EntregasDetalhe.LimpaTela;
begin
  stringGridExtrato.RowCount := 0;
end;


procedure Tview_EntregasDetalhe.ProcessExtrato(sentregador, sdata, scliente: String);
var
  FEntregas: TRESTEntregasDetalheController;
  sDescricao, sPeso, sRemessa: String;
  i: Integer;
begin
  try
    FEntregas := TRESTEntregasDetalheController.Create;
    if FEntregas.SearchEntregas(sentregador, sData, scliente) then
    begin
      DM_Main.memTableEntregasDetalhe.First;
      i := 0;
      while not DM_Main.memTableEntregasDetalhe.Eof do
      begin
        sDescricao := '';
        sPeso := '';
        sRemessa := '' ;
        if DM_Main.memTableEntregasDetalhedes_tipo.AsString = '' then
        begin
          sDescricao := 'ENTREGA';
        end
        else
        begin
          sDescricao := DM_Main.memTableEntregasDetalhedes_tipo.AsString;
        end;
        sRemessa := DM_Main.memTableEntregasDetalhenum_remessa.AsString;
        sPeso := ReplaceStr(DM_Main.memTableEntregasDetalheqtd_peso.AsString,',','');
        sPeso := ReplaceStr(sPeso,'.',',');
        stringGridExtrato.RowCount := (stringGridExtrato.RowCount + 1);
        i := Pred(stringGridExtrato.RowCount);
        stringGridExtrato.Cells[0,i] := sRemessa;
        stringGridExtrato.Cells[1,i] := sPeso;
        stringGridExtrato.Cells[2,i] := sDescricao;
        DM_Main.memTableEntregasDetalhe.Next;
      end;
    end;
  finally
    DM_Main.memTableEntregasDetalhe.Close;
    FEntregas.Free;
  end;
end;

end.
