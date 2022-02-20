unit Infra.DBEngine.FireDAC;

interface

uses
  SysUtils,
  Classes,
  DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,

  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,

  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.DApt.Intf,
  FireDAC.DApt,

  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract;

type
  TDbEngineFireDAC = class(TDbEngineFactory)
  private
    FConnectionComponent: TFDConnection;
  public
    function Connect: IDbEngineFactory; override;
    function ExecSQL(const ASQL: string): IDbEngineFactory; override;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet): IDbEngineFactory; override;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet): IDbEngineFactory; override;
    function StartTx: IDbEngineFactory; override;
    function CommitTX: IDbEngineFactory; override;
    function RollbackTx: IDbEngineFactory; override;
    function InTransaction: Boolean; override;
    function InjectConnection(AConn: TComponent; ATransactionObject: TObject): IDbEngineFactory; override;
    function ConnectionComponent: TComponent; override;

  public
    constructor Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''); override;
    destructor Destroy; override;

  end;

implementation

{$IF DEFINED(INFRA_ORMBR)} uses dbebr.factory.FireDAC; {$ENDIF}


function TDbEngineFireDAC.CommitTX: IDbEngineFactory;
begin
  Result := Self;
  TFDConnection(FConnectionComponent).Commit;
end;

function TDbEngineFireDAC.Connect: IDbEngineFactory;
begin
  inherited;
  Result := Self;
  FConnectionComponent.Connected := True;
end;

function TDbEngineFireDAC.ConnectionComponent: TComponent;
begin
  Result := FConnectionComponent;
end;

constructor TDbEngineFireDAC.Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = '');
var
  LDriverID: string;
begin
  inherited;
  LDriverID := ADbConfig.Driver.ToString;
  case ADbConfig.Driver of
    TDBDriver.Firebird:
      LDriverID := 'FB';
    TDBDriver.Interbase:
      LDriverID := 'IB';
    TDBDriver.Oracle:
      LDriverID := 'Ora';
    TDBDriver.PostgreSQL:
      LDriverID := 'PG';
  end;
  FConnectionComponent := TFDConnection.Create(nil);
  FConnectionComponent.FormatOptions.StrsTrim2Len := True;
  FConnectionComponent.DriverName := LDriverID;
  FConnectionComponent.TxOptions.Isolation := xiReadCommitted;
  FConnectionComponent.Params.Add('Database=' + FDbName);
  FConnectionComponent.Params.Add('User_Name=' + ADbConfig.User);
  FConnectionComponent.Params.Add('Password=' + ADbConfig.Password);
  FConnectionComponent.Params.Add('Protocol=TCPIP');
  FConnectionComponent.Params.Add('Port=' + IntToStr(ADbConfig.Port));
  FConnectionComponent.Params.Add('Server=' + ADbConfig.Host);
  FConnectionComponent.Params.Add('CharacterSet=' + ADbConfig.CharSet);
  FConnectionComponent.Params.Add('DriverID=' + LDriverID);
  FConnectionComponent.Params.Add('OpenMode=OpenOrCreate');
  FConnectionComponent.Params.Add('GUIDEndian=Big');
  FConnectionComponent.LoginPrompt := False;
{$IF DEFINED(INFRA_ORMBR)}
  FDBConnection := TFactoryFireDAC.Create(TFDConnection(FConnectionComponent), dnFirebird);
{$ENDIF}
end;

destructor TDbEngineFireDAC.Destroy;
begin
  FConnectionComponent.Free;
  inherited;
end;

function TDbEngineFireDAC.ExceSQL(const ASQL: string;
  var AResultDataSet: TDataSet): IDbEngineFactory;
begin
  Result := Self;
  if Assigned(AResultDataSet) then
    FreeAndNil(AResultDataSet);
  FConnectionComponent.ExecSQL(ASQL, AResultDataSet);
end;

function TDbEngineFireDAC.ExecSQL(const ASQL: string): IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.ExecSQL(ASQL);
end;

function TDbEngineFireDAC.InjectConnection(AConn: TComponent;
  ATransactionObject: TObject): IDbEngineFactory;
begin
  if not(AConn is TFDConnection) then
    raise Exception.Create('Invalid connection component instance for FireDAC. ' + Self.UnitName);
  FConnectionComponent := TFDConnection(AConn);
end;

function TDbEngineFireDAC.InTransaction: Boolean;
begin
  Result := FConnectionComponent.InTransaction;
end;

function TDbEngineFireDAC.OpenSQL(const ASQL: string;
  var AResultDataSet: TDataSet): IDbEngineFactory;
begin
  Result := Self;
  if Assigned(AResultDataSet) then
    FreeAndNil(AResultDataSet);
  FConnectionComponent.ExecSQL(ASQL, AResultDataSet);
end;

function TDbEngineFireDAC.RollbackTx: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.Rollback;
end;

function TDbEngineFireDAC.StartTx: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.StartTransaction;
end;

end.
