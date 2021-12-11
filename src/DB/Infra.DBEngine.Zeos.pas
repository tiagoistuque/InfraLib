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
  TDbEngineZeos = class(TDbEngineFactory)
  private
    FConnectionComponent: TZConnection;
  public
    function ConnectionComponent: TComponent; override;
    function Connect: IDbEngineFactory; override;
    function ExecSQL(const ASQL: string): IDbEngineFactory; override;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet ): IDbEngineFactory; override;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet ): IDbEngineFactory; override;
    function StartTx: IDbEngineFactory; override;
    function CommitTX: IDbEngineFactory; override;
    function RollbackTx: IDbEngineFactory; override;
    function InTransaction: Boolean; override;
    function InjectConnection(AConn: TComponent; ATransactionObject: TObject): IDbEngineFactory; override;

  public
    constructor Create(const ADbConfig: IDbEngineConfig); override;
    destructor Destroy; override;

  end;

implementation

{$IF DEFINED(INFRA_ORMBR)} uses dbebr.factory.Zeos; {$ENDIF}

function TDbEngineZeos.CommitTX: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.Commit;
end;

function TDbEngineZeos.Connect: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.Connect;
  inherited;
end;

function TDbEngineZeos.ConnectionComponent: TComponent;
begin
  Result := FConnectionComponent;
end;

constructor TDbEngineZeos.Create(const ADbConfig: IDbEngineConfig);
var
  LProtocol: string;
begin
  inherited;
  LProtocol := ADbConfig.Driver.ToString.ToLower;
  FConnectionComponent := TZConnection.Create(nil);
  with FConnectionComponent do
  begin
    Protocol := LProtocol;
    HostName := ADbConfig.Host;
    Port := ADbConfig.Port;
    Database := ADbConfig.Database;
    User := ADbConfig.User;
    Password := ADbConfig.Password;
    Connected := True;
  end;
  {$IF DEFINED(INFRA_ORMBR)}
  FDBConnection := TFactoryZeos.Create(FConnectionComponent, dnFirebird);
  {$ENDIF}
end;

destructor TDbEngineZeos.Destroy;
begin
  FConnectionComponent.Free;
  inherited;
end;

function TDbEngineZeos.ExceSQL(const ASQL: string;
  var AResultDataSet: TDataSet): IDbEngineFactory;
var
  LZQuery: TZQuery;
begin
  Result := Self;
  if Assigned(AResultDataSet) then
    FreeAndNil(AResultDataSet);
  LZQuery := TZQuery.Create(nil);
  try
    LZQuery.Connection := FConnectionComponent;
    LZQuery.SQL.Text := ASQL;
    LZQuery.Open;
  finally
    AResultDataSet := LZQuery;
  end;
end;

function TDbEngineZeos.ExecSQL(const ASQL: string): IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.ExecuteDirect(ASQL);
end;

function TDbEngineZeos.InjectConnection(AConn: TComponent;
  ATransactionObject: TObject): IDbEngineFactory;
begin
  if not (AConn is TZConnection) then
    raise Exception.Create('Invalid connection component instance for ZeosDBO. '+Self.UnitName);
  FConnectionComponent := TZConnection(AConn);
end;

function TDbEngineZeos.InTransaction: Boolean;
begin
  Result := FConnectionComponent.InTransaction;
end;

function TDbEngineZeos.OpenSQL(const ASQL: string;
  var AResultDataSet: TDataSet): IDbEngineFactory;
var
  LZQuery: TZQuery;
begin
  Result := Self;
  if Assigned(AResultDataSet) then
    FreeAndNil(AResultDataSet);
  LZQuery := TZQuery.Create(nil);
  try
    LZQuery.Connection := FConnectionComponent;
    LZQuery.SQL.Text := ASQL;
    LZQuery.Open;
  finally
    AResultDataSet := LZQuery;
  end;
end;

function TDbEngineZeos.RollbackTx: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.Rollback;
end;

function TDbEngineZeos.StartTx: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.StartTransaction;
end;

end.
