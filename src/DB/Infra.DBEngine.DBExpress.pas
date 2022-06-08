unit Infra.DBEngine.DBExpress;

interface

uses
  DB,
  Classes,
  SysUtils,
  SqlExpr,
  SimpleDS,
  DBXCommon,
  DBXFirebird,

  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract;

type
  TDbEngineDBExpress = class(TDbEngineAbstract)
  private
    FConnectionComponent: TSQLConnection;
    FTransactionComponent: TDBXTransaction;
    FInjectedConnection: Boolean;
    FInjectedTransaction: Boolean;
    FRowsAffected: Integer;
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
    function IsConnected: Boolean; override;
    function RowsAffected: Integer; override;
    function InjectConnection(AConn: TComponent; ATransactionObject: TObject): IDbEngineFactory; override;

  public
    constructor Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''); override;
    destructor Destroy; override;

  end;

implementation

{$IF DEFINED(INFRA_ORMBR)} uses dbebr.factory.DBExpress; {$IFEND}

function TDbEngineDBExpress.CommitTX: IDbEngineFactory;
begin
  Result := Self;
  if Assigned(FTransactionComponent) and (not FInjectedConnection) and (not FInjectedTransaction) then
    FConnectionComponent.CommitFreeAndNil(FTransactionComponent);
end;

function TDbEngineDBExpress.Connect: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.Connected := True;
  inherited;
end;

function TDbEngineDBExpress.ConnectionComponent: TComponent;
begin
  Result := FConnectionComponent;
end;

constructor TDbEngineDBExpress.Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = '');
begin
  inherited;
  if Assigned(ADbConfig) then
  begin
    FConnectionComponent := TSQLConnection.Create(nil);
    with FConnectionComponent do
    begin

      DriverName := 'Firebird';
      GetDriverFunc := 'getSQLDriverINTERBASE';
      KeepConnection := True;
      LoginPrompt := False;
      with Params do
      begin
        Clear;
        Add('Database=' + Format('%s/%d:%s', [ADbConfig.Host, ADbConfig.Port, FDBName]));
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
    {$IFEND}
  end;
end;

destructor TDbEngineDBExpress.Destroy;
begin
  if (not FInjectedConnection) and (not FInjectedTransaction) then
  begin
    if Assigned(FTransactionComponent) then
    begin
      FConnectionComponent.RollbackIncompleteFreeAndNil(FTransactionComponent);
    end;
    FConnectionComponent.Free;
  end;
  inherited;
end;

function TDbEngineDBExpress.ExceSQL(const ASQL: string;
  var AResultDataSet: TDataSet): IDbEngineFactory;
var
  LQuery: TSimpleDataSet;
begin
  Result := Self;
  LQuery := TSimpleDataSet.Create(nil);
  try
    LQuery.Connection := FConnectionComponent;
    LQuery.DataSet.CommandText := ASQL;
    LQuery.Open;
  finally
    AResultDataSet := LQuery;
  end;
end;

function TDbEngineDBExpress.ExecSQL(const ASQL: string): IDbEngineFactory;
begin
  Result := Self;
  FRowsAffected := FConnectionComponent.ExecuteDirect(ASQL);
end;

Function TDbEngineDBExpress.InjectConnection(AConn: TComponent;
  ATransactionObject: TObject): IDbEngineFactory;
begin
  Result := Self;
  if Assigned(FConnectionComponent) then
    FreeAndNil(FConnectionComponent);
  if not (AConn is TSQLConnection) then
    raise Exception.Create('Invalid connection component instance for DBExpress. '+Self.UnitName);
  FConnectionComponent := TSQLConnection(AConn);
  FInjectedConnection := True;
  if Assigned(ATransactionObject) then
  begin
    FTransactionComponent := TDBXTransaction(ATransactionObject);
    FInjectedTransaction := True;
  end;
end;

function TDbEngineDBExpress.InTransaction: Boolean;
begin
  Result := FConnectionComponent.InTransaction;
end;

function TDbEngineDBExpress.IsConnected: Boolean;
begin
  Result := Assigned(FConnectionComponent) and FConnectionComponent.Connected;
end;

function TDbEngineDBExpress.OpenSQL(const ASQL: string;
  var AResultDataSet: TDataSet): IDbEngineFactory;
var
  LQuery: TSimpleDataSet;
begin
  Result := Self;
  LQuery := TSimpleDataSet.Create(nil);
  try
    LQuery.Connection := FConnectionComponent;
    LQuery.DataSet.CommandText := ASQL;
    LQuery.DataSet.CommandType := ctQuery;
    LQuery.Open;
  finally
    AResultDataSet := LQuery;
  end;
end;

function TDbEngineDBExpress.RollbackTx: IDbEngineFactory;
begin
  Result := Self;
  if Assigned(FTransactionComponent) and (not FInjectedConnection) and (not FInjectedTransaction) then
    FConnectionComponent.RollbackFreeAndNil(FTransactionComponent);
end;

function TDbEngineDBExpress.RowsAffected: Integer;
begin
  Result := FRowsAffected;
end;

function TDbEngineDBExpress.StartTx: IDbEngineFactory;
begin
  Result := Self;
  if (not FInjectedConnection) and (not FInjectedTransaction) then
    FTransactionComponent :=  FConnectionComponent.BeginTransaction(TDBXIsolations.ReadCommitted);
end;

end.
