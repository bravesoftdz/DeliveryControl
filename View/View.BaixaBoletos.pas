unit View.BaixaBoletos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.ScrollBox, Controller.RESTBoletos, System.Actions, FMX.ActnList, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, MultiDetailAppearanceU, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope;

type
  Tview_BaixaBoletos = class(TForm)
    layoutTitle: TLayout;
    rectangleTitle: TRectangle;
    imageExit: TImage;
    layoutPadrao: TLayout;
    actionListBoletos: TActionList;
    actionExit: TAction;
    labelBoletos: TLabel;
    listViewBoletos: TListView;
    rectangleSave: TRectangle;
    labelSave: TLabel;
    labelTitle: TLabel;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    actionBaixar: TAction;
    procedure FormActivate(Sender: TObject);
    procedure actionExitExecute(Sender: TObject);
    procedure imageExitMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure rectangleSaveMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure rectangleSaveMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure actionBaixarExecute(Sender: TObject);
    procedure listViewBoletosItemClick(const Sender: TObject; const AItem: TListViewItem);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ListaBoletos;
    function BaixaBoleto(sLinha, sUsername: String): boolean;
  end;

var
  view_BaixaBoletos: Tview_BaixaBoletos;
  sLinhaGeral: String;

implementation

{$R *.fmx}

uses DM.Main, Common.Params;

{ Tview_BaixaBoletos }

procedure Tview_BaixaBoletos.actionBaixarExecute(Sender: TObject);
begin
  if sLinhaGeral = '' then
  begin
    ShowMessage('Selecione um boleto na lista!');
    Exit;
  end;
  MessageDlg('Confirma baixar o boleto?', System.UITypes.TMsgDlgType.mtConfirmation,
  [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo], 0,
  procedure (const AResult: System.UITypes.TModalResult)
  begin
    case AResult of
      mrYes:
      begin
        if not BaixaBoleto(sLinhaGeral, Common.Params.paramUserName) then
        begin
          ShowMessage('Ocorreu um problema ao tentar baixar o boleto! Comunique o Administrador.');
        end
        else
        begin
          ShowMessage('Boleto baixado com sucesso! Volte para a tela anterior e realize seu Login.');
          Close;
        end;
      end;
    end;
  end);
end;

procedure Tview_BaixaBoletos.actionExitExecute(Sender: TObject);
begin
  Close;
end;

function Tview_BaixaBoletos.BaixaBoleto(sLinha, sUsername: String): boolean;
var
  FBoletos: TRESTBoletosController;
begin
  try
    Result := FBoletos.BaixaBoleto(sLinha, sUsername);
  finally
    FBoletos.Free;
  end;
end;

procedure Tview_BaixaBoletos.FormActivate(Sender: TObject);
begin
  sLinhaGeral := '';
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
  i := 0;
  while not DM_Main.memTableBoletos.Eof do
  begin
    Inc(i ,1);
    sData := Copy(DM_Main.memTableBoletosdat_credito.AsString,9,2) + '/' + Copy(DM_Main.memTableBoletosdat_credito.AsString,6,2) +
             Copy(DM_Main.memTableBoletosdat_credito.AsString,1,4);
    DM_Main.memTableBoletos.Next;
  end;
end;

procedure Tview_BaixaBoletos.listViewBoletosItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  sLinhaGeral := DM_Main.memTableBoletosnum_linha_boleto.Text;
end;

procedure Tview_BaixaBoletos.rectangleSaveMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 0.7;
end;

procedure Tview_BaixaBoletos.rectangleSaveMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TRectangle(Sender).Opacity := 1;
  actionBaixarExecute(Sender);
end;

end.
