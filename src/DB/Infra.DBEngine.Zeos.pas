unit Infra.DBEngine.Zeos;

interface

uses
  DB,
  Classes,
  SysUtils,

  ZAbstractConnection,
  ZConnection,
  ZDataSet,
  ZCompatibility,
  ZDbcIntfs,
  ZSqlMonitor,

  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract;

type
  TDbEngineZeos = class(TDbEngineAbstract)
  private
    FConnectionComponent: TZConnection;
    FInjectedConnection: Boolean;
    FRowsAffected: Integer;
    FZSQLMonitor: TZSQLMonitor;
    FDbConfig: IDbEngineConfig;
    procedure TraceLogEvent(Sender: TObject; Event: TZLoggingEvent);
  public
    function ConnectionComponent: TComponent; override;
    procedure Connect; override;
    procedure Disconnect; override;
    function ExecSQL(const ASQL: string): Integer; override;
    function ExecSQL(const ASQL: string; var AResultDataSet: TDataSet): Integer; override;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet): Integer; override;
    procedure StartTx; override;
    procedure CommitTX; override;
    procedure RollbackTx; override;
    function InTransaction: Boolean; override;
    function IsConnected: Boolean; override;
    function RowsAffected: Integer; override;
    procedure InjectConnection(AConn: TComponent; ATransactionObject: TObject); override;

  public
    constructor Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''); override;
    destructor Destroy; override;

  end;

implementation

uses
  {$IF DEFINED(INFRA_ORMBR)} dbebr.factory.Zeos, {$IFEND}
  Infra.DBEngine.Trace, Infra.DBEngine.Context,
  Infra.DBDriver.Register;

procedure TDbEngineZeos.CommitTX;
begin
  FConnectionComponent.Commit;
end;

procedure TDbEngineZeos.Connect;
begin
  if not FConnectionComponent.Connected then
    FConnectionComponent.Connected := True;
  inherited;
end;

function TDbEngineZeos.ConnectionComponent: TComponent;
begin
  Result := FConnectionComponent;
end;

constructor TDbEngineZeos.Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = '');
var
  LProtocol: string;
begin
  inherited;
  FDbConfig := ADbConfig;
  LProtocol := DBDriverToStr(ADbConfig.Driver).ToLower;
  FConnectionComponent := TZConnection.Create(nil);
  with FConnectionComponent do
  begin
    Protocol := LProtocol;
    HostName := ADbConfig.Host;
    Port := ADbConfig.Port;
    Database := FDBName;
    User := ADbConfig.User;
    Password := ADbConfig.Password;
    ClientCodepage := ADbConfig.CharSet;
    // ControlsCodePage := cCP_UTF8;
    TransactIsolationLevel := tiReadCommitted;
    Connected := True;
  end;
  if ADbConfig.SaveTrace then
  begin
    FZSQLMonitor := TZSQLMonitor.Create(nil);
    FZSQLMonitor.Active := True;
    FZSQLMonitor.AutoSave := False;
    FZSQLMonitor.OnLogTrace := TraceLogEvent;

  end;
  {$IF DEFINED(INFRA_ORMBR)}
  FDBConnection := TFactoryZeos.Create(FConnectionComponent, TDBDriverRegister.GetDriverName(ADbConfig.Driver));
  {$IFEND}
end;

destructor TDbEngineZeos.Destroy;
begin
  if (not FInjectedConnection) then
  begin
    if FConnectionComponent.InTransaction then
      FConnectionComponent.Rollback;
    FConnectionComponent.Free;
  end;
  if Assigned(FZSQLMonitor) then
  begin
    FZSQLMonitor.Free;
  end;
  inherited;
end;

procedure TDbEngineZeos.Disconnect;
begin
  if FConnectionComponent.Connected then
    FConnectionComponent.Connected := False;
  inherited;
end;

function TDbEngineZeos.ExecSQL(const ASQL: string;
  var AResultDataSet: TDataSet): Integer;
var
  LZQuery: TZQuery;
begin
  if Assigned(AResultDataSet) then
    FreeAndNil(AResultDataSet);
  LZQuery := TZQuery.Create(nil);
  try
    LZQuery.Connection := FConnectionComponent;
    LZQuery.SQL.Text := ASQL;
    LZQuery.Open;
    Result := LZQuery.RecordCount;
  finally
    AResultDataSet := LZQuery;
  end;
end;

function TDbEngineZeos.ExecSQL(const ASQL: string): Integer;
begin
  FConnectionComponent.ExecuteDirect(ASQL, FRowsAffected);
  Result := FRowsAffected;
end;

procedure TDbEngineZeos.InjectConnection(AConn: TComponent;
  ATransactionObject: TObject);
begin
  if not(AConn is TZConnection) then
    raise Exception.Create('Invalid connection component instance for ZeosDBO. ' + Self.UnitName);
  if Assigned(FConnectionComponent) then
    FreeAndNil(FConnectionComponent);
  FConnectionComponent := TZConnection(AConn);
  {$IF DEFINED(INFRA_ORMBR)}
  FDBConnection := TFactoryZeos.Create(FConnectionComponent, TDBDriverRegister.GetDriverName(FDbConfig.Driver));
  {$IFEND}
  FInjectedConnection := True;
end;

function TDbEngineZeos.InTransaction: Boolean;
begin
  Result := FConnectionComponent.InTransaction;
end;

function TDbEngineZeos.IsConnected: Boolean;
begin
  Result := FConnectionComponent.Connected;
end;

function TDbEngineZeos.OpenSQL(const ASQL: string;
  var AResultDataSet: TDataSet): Integer;
var
  LZQuery: TZQuery;
begin
  if Assigned(AResultDataSet) then
    FreeAndNil(AResultDataSet);
  LZQuery := TZQuery.Create(nil);
  try
    LZQuery.Connection := FConnectionComponent;
    LZQuery.SQL.Text := ASQL;
    LZQuery.Open;
    Result := LZQuery.RecordCount;
  finally
    AResultDataSet := LZQuery;
  end;
end;

procedure TDbEngineZeos.RollbackTx;
begin
  if (not FInjectedConnection) then
    FConnectionComponent.Rollback;
end;

function TDbEngineZeos.RowsAffected: Integer;
begin
  Result := FRowsAffected;
end;

procedure TDbEngineZeos.StartTx;
begin
  if not FConnectionComponent.Connected then
    FConnectionComponent.Connected := True;
  if (not FInjectedConnection) then
    FConnectionComponent.StartTransaction;
end;

procedure TDbEngineZeos.TraceLogEvent(Sender: TObject; Event: TZLoggingEvent);
var
  Msg: string;
  LDbEngineTraceLog: TDbEngineTrace;
  LDbEngineContextRequest: TDbEngineContextRequest;
begin
  Msg := Event.Message;
  LDbEngineTraceLog := TDbEngineTrace.Create(Msg, FDBName);
  try
    LDbEngineContextRequest := TDbEngineTraceManager.DbEngineContextRequest();
    LDbEngineContextRequest(LDbEngineTraceLog);
  finally
    LDbEngineTraceLog.Free;
  end;
end;

end.
