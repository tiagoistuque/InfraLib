unit Infra.DBEngine.FireDAC;

interface

uses
  SysUtils,
  Classes,
  DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,

  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,

  FireDAC.Phys.MSAcc,
  FireDAC.Phys.MSAccDef,

  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLCli,
  FireDAC.Phys.MSSQLMeta,
  FireDAC.Phys.MSSQLWrapper,

  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.DApt.Intf,
  FireDAC.DApt,

  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract;

type
  TDbEngineFireDAC = class(TDbEngineAbstract)
  private
    FConnectionComponent: TFDConnection;
    FInjectedConnection: Boolean;
    FRowsAffected: Integer;
  public
    procedure Connect; override;
    procedure Disconnect; override;
    function ExecSQL(const ASQL: string): Integer; override;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet): Integer; override;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet): Integer; override;
    procedure StartTx; override;
    procedure CommitTX; override;
    procedure RollbackTx; override;
    function InTransaction: Boolean; override;
    function IsConnected: Boolean; override;
    function RowsAffected: Integer; override;
    procedure InjectConnection(AConn: TComponent; ATransactionObject: TObject); override;
    function ConnectionComponent: TComponent; override;

  public
    constructor Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''); override;
    destructor Destroy; override;

  end;

implementation

uses
  {$IF DEFINED(INFRA_ORMBR)}dbebr.factory.FireDAC, {$IFEND}
  Infra.DBDriver.Register;

procedure TDbEngineFireDAC.CommitTX;
begin
  TFDConnection(FConnectionComponent).Commit;
end;

procedure TDbEngineFireDAC.Connect;
begin
  inherited;
  FConnectionComponent.Connected := True;
end;

function TDbEngineFireDAC.ConnectionComponent: TComponent;
begin
  Result := FConnectionComponent;
end;

constructor TDbEngineFireDAC.Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = '');
var
  LDriverID: string;
  LOpenMode: string;
  LGUIDEndian: string;
  LAuthMode: string;
  LProtocol: string;
begin
  inherited;
  // for complete parameters definitions see : https://docwiki.embarcadero.com/RADStudio/Sydney/en/Database_Connectivity_(FireDAC)
  if Assigned(ADbConfig) then
  begin
    LGUIDEndian := EmptyStr;
    LOpenMode := EmptyStr;
    LAuthMode := EmptyStr;
    LProtocol := EmptyStr;
    LDriverID := DBDriverToStr(ADbConfig.Driver);
    case ADbConfig.Driver of
      TDBDriver.Firebird:
        begin
          LDriverID := 'FB';
          LGUIDEndian := 'Big';
          LOpenMode := 'OpenOrCreate';
          LProtocol := 'TCPIP';
          if not ADbConfig.GetExecuteMigrations then
            LOpenMode := 'Open';
        end;
      TDBDriver.FirebirdEmbedded:
        begin
          LDriverID := 'FBEmbedded';
          LGUIDEndian := 'Big';
          LOpenMode := 'OpenOrCreate';
          LProtocol := 'local';
          if not ADbConfig.GetExecuteMigrations then
            LOpenMode := 'Open';
        end;
      TDBDriver.Interbase:
        begin
          LDriverID := 'IB';
          LOpenMode := 'OpenOrCreate';
          LProtocol := 'TCPIP';
          if not ADbConfig.GetExecuteMigrations then
            LOpenMode := 'Open';
        end;
      TDBDriver.Oracle:
        begin
          LDriverID := 'Ora';
          LAuthMode := 'SysDBA';
        end;
      TDBDriver.PostgreSQL:
        begin
          LDriverID := 'PG';
        end;
    end;
    FConnectionComponent := TFDConnection.Create(nil);
    FConnectionComponent.FormatOptions.StrsTrim2Len := True;
    FConnectionComponent.DriverName := LDriverID;
    FConnectionComponent.TxOptions.Isolation := xiReadCommitted;
    FConnectionComponent.Params.Add('Database=' + FDbName);
    FConnectionComponent.Params.Add('User_Name=' + ADbConfig.User);
    if not LProtocol.IsEmpty then
      FConnectionComponent.Params.Add('Protocol=' + LProtocol);
    if ADbConfig.Driver <> TDBDriver.FirebirdEmbedded then
    begin
      FConnectionComponent.Params.Add('Password=' + ADbConfig.Password);
      FConnectionComponent.Params.Add('Port=' + IntToStr(ADbConfig.Port));
      FConnectionComponent.Params.Add('Server=' + ADbConfig.Host);
    end;
    FConnectionComponent.Params.Add('CharacterSet=' + ADbConfig.CharSet);
    FConnectionComponent.Params.Add('DriverID=' + LDriverID);
    if not LOpenMode.IsEmpty then
      FConnectionComponent.Params.Add('OpenMode=' + LOpenMode);
    if not LGUIDEndian.IsEmpty then
      FConnectionComponent.Params.Add('GUIDEndian=' + LGUIDEndian);
    FConnectionComponent.LoginPrompt := False;
    {$IF DEFINED(INFRA_ORMBR)}
    FDBConnection := TFactoryFireDAC.Create(TFDConnection(FConnectionComponent), TDBDriverRegister.GetDriverName(ADbConfig.Driver));
    {$IFEND}
  end;
end;

destructor TDbEngineFireDAC.Destroy;
begin
  if (not FInjectedConnection) then
  begin
    if IsConnected then
      FConnectionComponent.Rollback;
    FConnectionComponent.Free;
  end;
  inherited;
end;

procedure TDbEngineFireDAC.Disconnect;
begin
  FConnectionComponent.Connected := False;
end;

function TDbEngineFireDAC.ExceSQL(const ASQL: string;
  var AResultDataSet: TDataSet): Integer;
begin
  if Assigned(AResultDataSet) then
    FreeAndNil(AResultDataSet);
  FRowsAffected := FConnectionComponent.ExecSQL(ASQL, AResultDataSet);
  Result := FRowsAffected;
end;

function TDbEngineFireDAC.ExecSQL(const ASQL: string): Integer;
begin
  FRowsAffected := FConnectionComponent.ExecSQL(ASQL);
  Result := FRowsAffected;
end;

procedure TDbEngineFireDAC.InjectConnection(AConn: TComponent;
  ATransactionObject: TObject);
begin
  if not(AConn is TFDConnection) then
    raise Exception.Create('Invalid connection component instance for FireDAC. ' + Self.UnitName);
  if Assigned(FConnectionComponent) then
    FreeAndNil(FConnectionComponent);
  FInjectedConnection := True;
  FConnectionComponent := TFDConnection(AConn);
end;

function TDbEngineFireDAC.InTransaction: Boolean;
begin
  Result := FConnectionComponent.InTransaction;
end;

function TDbEngineFireDAC.IsConnected: Boolean;
begin
  Result := FConnectionComponent.Connected;
end;

function TDbEngineFireDAC.OpenSQL(const ASQL: string;
  var AResultDataSet: TDataSet): Integer;
begin
  if Assigned(AResultDataSet) then
    FreeAndNil(AResultDataSet);
  FConnectionComponent.ExecSQL(ASQL, AResultDataSet);
  Result := AResultDataSet.RecordCount;
end;

procedure TDbEngineFireDAC.RollbackTx;
begin
  if (not FInjectedConnection) then
    FConnectionComponent.Rollback;
end;

function TDbEngineFireDAC.RowsAffected: Integer;
begin
  Result := FRowsAffected;
end;

procedure TDbEngineFireDAC.StartTx;
begin
  if InTransaction then
    raise EStartTransactionException.Create('Necessário commit ou rollback da transação anterior para iniciar uma nova transação.');
  if not FConnectionComponent.Connected then
    FConnectionComponent.Connected := True;
  if (not FInjectedConnection) then
    FConnectionComponent.StartTransaction;
end;

end.
