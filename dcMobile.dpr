program dcMobile;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Login in 'View\View.Login.pas' {view_Login},
  DM.Main in 'DAO\DM.Main.pas' {DM_Main: TDataModule},
  Model.Usuarios in 'Model\Model.Usuarios.pas',
  Controller.Usuarios in 'Controller\Controller.Usuarios.pas',
  Common.Notificacao in 'Common\Common.Notificacao.pas',
  Common.Params in 'Common\Common.Params.pas',
  Model.RESTCadastro in 'Model\Model.RESTCadastro.pas',
  Controller.RESTCadastro in 'Controller\Controller.RESTCadastro.pas',
  View.Extratos in 'View\View.Extratos.pas' {view_Extratos},
  View.Main in 'View\View.Main.pas' {view_Main},
  Model.RESTLogin in 'Model\Model.RESTLogin.pas',
  Controller.RESTLogin in 'Controller\Controller.RESTLogin.pas',
  View.Boletos in 'View\View.Boletos.pas' {view_Boletos},
  Model.RESTExtrato in 'Model\Model.RESTExtrato.pas',
  Controller.RESTExtratos in 'Controller\Controller.RESTExtratos.pas',
  Model.RESTPlanilhaCredito in 'Model\Model.RESTPlanilhaCredito.pas',
  Controller.RESTPlanilhaCredito in 'Controller\Controller.RESTPlanilhaCredito.pas',
  View.Cadastro in 'View\View.Cadastro.pas' {view_Cadastro},
  Model.RESTBoletos in 'Model\Model.RESTBoletos.pas',
  Controller.RESTBoletos in 'Controller\Controller.RESTBoletos.pas',
  View.BaixaBoletos in 'View\View.BaixaBoletos.pas' {view_BaixaBoletos};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM_Main, DM_Main);
  Application.CreateForm(Tview_Login, view_Login);
  Application.Run;
end.