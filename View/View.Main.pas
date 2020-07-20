unit View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  System.Actions, FMX.ActnList;

type
  Tview_Main = class(TForm)
    layoutPadrao: TLayout;
    actionListMenu: TActionList;
    actionExit: TAction;
    layoutMenu: TLayout;
    rectangleExtrato: TRectangle;
    labelExtrato: TLabel;
    actionExtratos: TAction;
    rectangleBoleto: TRectangle;
    labelBoleto: TLabel;
    actionBoletos: TAction;
    layoutTitle: TLayout;
    rectangleTitle: TRectangle;
    labelTitle: TLabel;
    imageExit: TImage;
    procedure imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure actionExitExecute(Sender: TObject);
    procedure rectangleExtratoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure rectangleExtratoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure actionExtratosExecute(Sender: TObject);
    procedure rectangleBoletoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure rectangleBoletoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure actionBoletosExecute(Sender: TObject);
  private
    { Private declarations }
    procedure OpenFormExtratos;
    procedure OpenFormBoletos;
  public
    { Public declarations }
  end;

var
  view_Main: Tview_Main;

implementation

{$R *.fmx}

uses View.Extratos, View.Boletos;

procedure Tview_Main.actionBoletosExecute(Sender: TObject);
begin
  OpenFormBoletos;
end;

procedure Tview_Main.actionExitExecute(Sender: TObject);
begin
  Close;
end;

procedure Tview_Main.actionExtratosExecute(Sender: TObject);
begin
  OpenFormExtratos;
end;

procedure Tview_Main.imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  actionExitExecute(Sender);
end;
procedure Tview_Main.OpenFormBoletos;
begin
  if not Assigned(view_Boletos) then
  begin
    Application.CreateForm(Tview_Boletos, view_Boletos);
  end;
  view_Boletos.Show;
end;

procedure Tview_Main.OpenFormExtratos;
begin
  if not Assigned(view_Extratos) then
  begin
    Application.CreateForm(Tview_Extratos, view_Extratos);
  end;
  view_Extratos.Show;
end;

procedure Tview_Main.rectangleBoletoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 0.8;
end;

procedure Tview_Main.rectangleBoletoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 1;
  actionBoletosExecute(Sender);
end;

procedure Tview_Main.rectangleExtratoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 0.8;
end;

procedure Tview_Main.rectangleExtratoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 1;
  actionExtratosExecute(Sender);
end;

end.
