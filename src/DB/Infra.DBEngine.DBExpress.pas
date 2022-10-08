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
    procedure Connect; override;
    function ExecSQL(const ASQL: string): Integer; override;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet ): Integer; override;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet ): Integer; override;
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

{$IF DEFINED(INFRA_ORMBR)} uses dbebr.factory.DBExpress; {$IFEND}

procedure TDbEngineDBExpress.CommitTX;
begin
  if Assigned(FTransactionComponent) and (not FInjectedTransaction) then
    FTransactionComponent.Connection.CommitFreeAndNil(FTransactionComponent);
end;

procedure TDbEngineDBExpress.Connect;
begin
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
  if Assigned(FTransactionComponent) and (not FInjectedTransaction) then
  begin
    FTransactionComponent.Connection.RollbackIncompleteFreeAndNil(FTransactionComponent);
  end;
  if (not FInjectedConnection) then
  begin
    FConnectionComponent.Free;
  end;
  inherited;
end;

function TDbEngineDBExpress.ExceSQL(const ASQL: string;
  var AResultDataSet: TDataSet): Integer;
var
  LQuery: TSimpleDataSet;
begin
  LQuery := TSimpleDataSet.Create(nil);
  try
    LQuery.Connection := FConnectionComponent;
    LQuery.DataSet.CommandText := ASQL;
    LQuery.Open;
    Result := LQuery.RecordCount
  finally
    AResultDataSet := LQuery;
  end;
end;

function TDbEngineDBExpress.ExecSQL(const ASQL: string): Integer;
begin
  FRowsAffected := FConnectionComponent.ExecuteDirect(ASQL);
  Result := FRowsAffected;
end;

procedure TDbEngineDBExpress.InjectConnection(AConn: TComponent;
  ATransactionObject: TObject);
begin
  if not (AConn is TSQLConnection) then
    raise Exception.Create('Invalid connection component instance for DBExpress. '+Self.UnitName);
  if Assigned(FConnectionComponent) then
    FreeAndNil(FConnectionComponent);
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
  Result := FConnectionComponent.InTransaction or Assigned(FTransactionComponent);
end;

function TDbEngineDBExpress.IsConnected: Boolean;
begin
  Result := Assigned(FConnectionComponent) and FConnectionComponent.Connected;
end;

function TDbEngineDBExpress.OpenSQL(const ASQL: string;
  var AResultDataSet: TDataSet): Integer;
var
  LQuery: TSimpleDataSet;
begin
  LQuery := TSimpleDataSet.Create(nil);
  try
    LQuery.Connection := FConnectionComponent;
    LQuery.DataSet.CommandText := ASQL;
    LQuery.DataSet.CommandType := ctQuery;
    LQuery.Open;
    Result := LQuery.RecordCount;
  finally
    AResultDataSet := LQuery;
  end;
end;

procedure TDbEngineDBExpress.RollbackTx;
begin
  if Assigned(FTransactionComponent) and (not FInjectedTransaction) then
    FTransactionComponent.Connection.RollbackFreeAndNil(FTransactionComponent);
end;

function TDbEngineDBExpress.RowsAffected: Integer;
begin
  Result := FRowsAffected;
end;

procedure TDbEngineDBExpress.StartTx;
begin
  if InTransaction then
    raise EStartTransactionException.Create('Necessário commit ou rollback da transação anterior para iniciar uma nova transação.');
  if (not FInjectedConnection) and (not FInjectedTransaction) then
    FTransactionComponent :=  FConnectionComponent.DBXConnection.BeginTransaction(TDBXIsolations.ReadCommitted);
end;

end.
