unit Model.RESTCadastro;

interface

uses Web.HTTPApp, System.JSON, REST.Types, System.SysUtils, System.Classes;

type
  TRESTCadastro = class
  private
    procedure StartRestClient(sFile: String);
    procedure StartRestRequest(sFile: String);
  public
    function SalvaCadastro(sCpfCnpj, sUserName, sName, sPassword, sEmail: String): boolean;
    function UsuarioExiste(sCPF: String): Boolean;
    function CPFValido(sCPF: string): boolean;
  end;
const
  API = '/api/dc';

implementation

uses Common.Notificacao, Common.Params, DM.Main;

{ TRESTCadastro }

procedure TRESTCadastro.StartRestClient(sFile: String);
begin
  DM_Main.RESTClient.Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  DM_Main.RESTClient.AcceptCharset := 'utf-8, *;q=0.8';
  DM_Main.RESTClient.BaseURL := Common.Params.paramBaseURL + API + sFile;
  DM_Main.RESTClient.RaiseExceptionOn500 := False;
end;

procedure TRESTCadastro.StartRestRequest(sFile: String);
begin
  StartRestClient(sFile);
  DM_Main.RESTRequest.Client := DM_Main.RESTClient;
  DM_Main.RESTRequest.Accept := DM_Main.RESTClient.Accept;
  DM_Main.RESTRequest.AcceptCharset := DM_Main.RESTClient.AcceptCharset;
  DM_Main.RESTRequest.Method := rmPOST;
end;

function TRESTCadastro.UsuarioExiste(sCPF: String): Boolean;
begin
  Result := False;
  StartRestRequest('/dc_usuario_existe.php');
  DM_Main.RESTRequest.AddParameter('cpf', sCpf, pkGETorPOST);
  DM_Main.RESTResponseDataSetAdapter.Active := False;
  DM_Main.RESTRequest.Execute;
  if DM_Main.RESTResponse.JSONText = 'false' then
  begin
    Exit;
  end;
  Result := True;
end;

function TRESTCadastro.CPFValido(sCPF: string): boolean;
var
  jsonObj, jo: TJSONObject;
  jvCodigo, jvNome, jvAtivo, jvCadastro: TJSONValue;
  ja: TJSONArray;
  i: integer;
begin
  Result := False;
  StartRestRequest('/dc_cpf_entregador.php');
  DM_Main.RESTRequest.AddParameter('cpf', sCpf, pkGETorPOST);
  DM_Main.RESTResponseDataSetAdapter.Active := False;
  DM_Main.RESTRequest.Execute;
  if DM_Main.RESTResponse.JSONText = 'false' then
  begin
    Exit;
  end;
  if DM_Main.RESTResponse.JSONValue is TJSONArray then
  begin
    ja := DM_Main.RESTResponse.JSONValue as TJSONArray;
    jsonObj := (ja.Get(0) as TJSONObject);
    jvCodigo := jsonObj.Get(1).JsonValue;
    jvNome := jsonObj.Get(2).JsonValue;
    jvAtivo := jsonObj.Get(9).JsonValue;
    jvCadastro := jsonObj.Get(0).JsonValue;
    Common.Params.paramCodeDelivery := StrToIntDef(jvCodigo.Value, 0);
    Common.Params.paramCodigoCadastro := StrToIntDef(jvCadastro.Value, 0);
    Common.Params.paramNameUser := jvnome.Value;
    Common.Params.paramEntregadorAtivo := StrToIntDef(jvAtivo.Value, 0);

  end
  else
  begin
    Exit;
  end;
  Result := True;
end;

function TRESTCadastro.SalvaCadastro(sCpfCnpj, sUserName, sName, sPassword, sEmail: String): boolean;
begin
  Result := False;
  StartRestRequest('/dc_salva_usuario.php');
  DM_Main.RESTRequest.AddParameter('cpf', sCpfCnpj, pkGETorPOST);
  DM_Main.RESTRequest.AddParameter('username', sUserName, pkGETorPOST);
  DM_Main.RESTRequest.AddParameter('name', sName, pkGETorPOST);
  DM_Main.RESTRequest.AddParameter('password', sPassword, pkGETorPOST);
  DM_Main.RESTRequest.AddParameter('email', sEmail, pkGETorPOST);
  DM_Main.RESTResponseDataSetAdapter.Active := False;
  DM_Main.RESTRequest.Execute;
  if DM_Main.RESTResponse.JSONText = 'false' then
  begin
    Exit;
  end;
  Result := True;
end;

end.
