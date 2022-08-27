unit Infra.DBEngine.Zeos;

interface

uses
  DB,
  Classes,
  SysUtils,

  ZAbstractConnection,
  ZConnection,
  ZDataSet,

  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract;

type
  TDbEngineZeos = class(TDbEngineAbstract)
  private
    FConnectionComponent: TZConnection;
  	FInjectedConnection: Boolean;
    FRowsAffected: Integer;
  public
    function ConnectionComponent: TComponent; override;
    procedure Connect; override;
    function ExecSQL(const ASQL: string): Integer; override;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet ): Integer; override;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet ): Integer; override;
    procedure StartTx; override;
    procedure CommitTX; override;
    procedure RollbackTx; override;
    function InTransaction: Boolean; override;
    function RowsAffected: Integer; override;
    procedure InjectConnection(AConn: TComponent; ATransactionObject: TObject); override;

  public
    constructor Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''); override;
    destructor Destroy; override;

  end;

implementation

{$IF DEFINED(INFRA_ORMBR)} uses dbebr.factory.Zeos; {$IFEND}

procedure TDbEngineZeos.CommitTX;
begin
  FConnectionComponent.Commit;
end;

procedure TDbEngineZeos.Connect;
begin
  FConnectionComponent.Connect;
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
    Connected := True;
  end;
  {$IF DEFINED(INFRA_ORMBR)}
  FDBConnection := TFactoryZeos.Create(FConnectionComponent, dnFirebird);
  {$IFEND}
end;

destructor TDbEngineZeos.Destroy;
begin
  if (not FInjectedConnection) then
  begin
    FConnectionComponent.Rollback;
    FConnectionComponent.Free;
  end;
  inherited;
end;

function TDbEngineZeos.ExceSQL(const ASQL: string;
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
  if not (AConn is TZConnection) then
    raise Exception.Create('Invalid connection component instance for ZeosDBO. '+Self.UnitName);
  if Assigned(FConnectionComponent) then
    FreeAndNil(FConnectionComponent);
  FInjectedConnection := True;
  FConnectionComponent := TZConnection(AConn);
end;

function TDbEngineZeos.InTransaction: Boolean;
begin
  Result := FConnectionComponent.InTransaction;
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

end.
