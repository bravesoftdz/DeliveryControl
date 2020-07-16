unit View.BaixaBoletos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.ScrollBox, Controller.RESTBoletos, System.Actions, FMX.ActnList;

type
  Tview_BaixaBoletos = class(TForm)
    layoutTitle: TLayout;
    rectangleTitle: TRectangle;
    imageExit: TImage;
    labelTitle: TLabel;
    layoutPadrao: TLayout;
    stringGridBoletos: TStringGrid;
    columnVencimento: TColumn;
    columnValor: TColumn;
    checkColumnOK: TCheckColumn;
    actionListBoletos: TActionList;
    actionExit: TAction;
    labelBoletos: TLabel;
    stringColumnLinha: TStringColumn;
    procedure FormActivate(Sender: TObject);
    procedure actionExitExecute(Sender: TObject);
    procedure imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ListaBoletos;
  end;

var
  view_BaixaBoletos: Tview_BaixaBoletos;

implementation

{$R *.fmx}

uses DM.Main;

{ Tview_BaixaBoletos }

procedure Tview_BaixaBoletos.actionExitExecute(Sender: TObject);
begin
  Close;
end;

procedure Tview_BaixaBoletos.FormActivate(Sender: TObject);
begin
  ListaBoletos;
end;

procedure Tview_BaixaBoletos.imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  actionExitExecute(Sender);
end;

procedure Tview_BaixaBoletos.ListaBoletos;
var
  i: integer;
  sData: String;
begin
  if DM_Main.memTableBoletos.IsEmpty then
  begin
    Close;
    Exit;
  end;
  DM_Main.memTableBoletos.First;
  stringGridBoletos.RowCount := 0;
  i := 0;
  while not DM_Main.memTableBoletos.Eof do
  begin
    Inc(i ,1);
    stringGridBoletos.RowCount := i;
    sData := Copy(DM_Main.memTableBoletosdat_credito.AsString,9,2) + '/' + Copy(DM_Main.memTableBoletosdat_credito.AsString,6,2) +
             Copy(DM_Main.memTableBoletosdat_credito.AsString,1,4);
    stringGridBoletos.Cells[0,Pred(i)] := DM_Main.memTableBoletosnum_linha_boleto.AsString;
    stringGridBoletos.Cells[1,Pred(i)] := sData;
    stringGridBoletos.Cells[2,Pred(i)] := FormatFloat('###,##0.00;-###,##0.00', StrToFloat(DM_Main.memTableBoletosval_boleto.AsString));
    stringGridBoletos.Cells[3,Pred(i)] := DM_Main.memTableBoletosdom_recebido.AsString;
    DM_Main.memTableBoletos.Next;
  end;
  DM_Main.memTableBoletos.Close;
end;

end.
