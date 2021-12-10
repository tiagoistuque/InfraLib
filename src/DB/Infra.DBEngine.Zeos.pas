unit Infra.DBEngine.Zeos;

interface

uses
  Classes,
  SysUtils,

  ZConnection,

  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract;

type
  TDbEngineZeos = class(TDbEngineAbstract)
  private
    FConnectionComponent: TZConnection;
  public
    function StartTx: IDbEngineFactory; override;
    function CommitTX: IDbEngineFactory; override;
    function RollbackTx: IDbEngineFactory; override;
    function InTransaction: Boolean; override;
    function InjectConnection(AConn: TComponent; ATransactionObject: TObject): IDbEngineFactory; override;
    function ConnectionComponent: TComponent; override;

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

function TDbEngineZeos.ConnectionComponent: TComponent;
begin
  Result := FConnectionComponent;
end;

constructor TDbEngineZeos.Create(const ADbConfig: IDbEngineConfig);
begin
  inherited;
  FConnectionComponent := TZConnection.Create(nil);
  with FConnectionComponent do
  begin
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
