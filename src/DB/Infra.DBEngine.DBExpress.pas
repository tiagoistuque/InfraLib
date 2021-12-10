unit Infra.DBEngine.DBExpress;

interface

uses
  Classes,
  SysUtils,
  SqlExpr,
  DBXCommon,

  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract;

type
  TDbEngineDBExpress = class(TDbEngineAbstract)
  private
    FConnectionComponent: TSQLConnection;
    FTransactionComponent: TDBXTransaction;
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

{$IF DEFINED(INFRA_ORMBR)} uses dbebr.factory.DBExpress; {$ENDIF}

function TDbEngineDBExpress.CommitTX: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.CommitFreeAndNil(FTransactionComponent);
end;

function TDbEngineDBExpress.ConnectionComponent: TComponent;
begin
  Result := FConnectionComponent;
end;

constructor TDbEngineDBExpress.Create(const ADbConfig: IDbEngineConfig);
begin
  inherited;
  FConnectionComponent := TSQLConnection.Create(nil);
  with FConnectionComponent do
  begin
    DriverName := 'Firebird';
    GetDriverFunc := 'getSQLDriverINTERBASE';
    KeepConnection := True;
    LibraryName := 'dbxfb.dll';
    LoginPrompt := False;
    VendorLib := 'fbclient.dll';
    with Params do
    begin
      Clear;
      Add('Database=' + ADBConfig.Database);
      Add('Rolename=Rolename');
      Add('User_name=' + ADBConfig.User);
      Add('Password=' + ADBConfig.Password);
      Add('SQLDialect=3');
      Add('ServerCharSet=' + ADBConfig.CharSet);
      Add('Isolationlevel=ReadCommitted');
    end;
    Connected := True;
  end;
  {$IF DEFINED(INFRA_ORMBR)}
  FDBConnection := TFactoryDBExpress.Create(FConnectionComponent, dnFirebird);
  {$ENDIF}
end;

destructor TDbEngineDBExpress.Destroy;
begin
  if Assigned(FTransactionComponent) then
    FConnectionComponent.RollbackIncompleteFreeAndNil(FTransactionComponent);
  FConnectionComponent.Free;
  inherited;
end;

function TDbEngineDBExpress.InjectConnection(AConn: TComponent;
  ATransactionObject: TObject): IDbEngineFactory;
begin
  if not (AConn is TSQLConnection) then
    raise Exception.Create('Invalid connection component instance for DBExpress. '+Self.UnitName);
  FConnectionComponent := TSQLConnection(AConn);
end;

function TDbEngineDBExpress.InTransaction: Boolean;
begin
  Result := FConnectionComponent.InTransaction;
end;

function TDbEngineDBExpress.RollbackTx: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.RollbackFreeAndNil(FTransactionComponent);
end;

function TDbEngineDBExpress.StartTx: IDbEngineFactory;
begin
  Result := Self;
  FTransactionComponent :=  FConnectionComponent.BeginTransaction(TDBXIsolations.ReadCommitted);
end;

end.
