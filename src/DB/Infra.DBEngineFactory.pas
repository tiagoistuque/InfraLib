unit Infra.DBEngineFactory;

interface

uses

  {$IF DEFINED(USE_FIREDAC)}
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.DApt.Intf, FireDAC.DApt,
  {$ELSE}
  SqlExpr, DBXCommon,
  {$ENDIF}
  {$IFDEF USE_ORMBR}
  dbcbr.ddl.commands,
  dbebr.factory.interfaces,
  {$IF DEFINED(USE_FIREDAC)}dbebr.factory.FireDAC, {$ELSE} dbebr.factory.dbexpress, {$ENDIF}
  ormbr.modeldb.compare,
  ormbr.metadata.classe.factory,
  dbcbr.database.compare,
  dbcbr.metadata.DB.factory,
  dbcbr.database.interfaces,

  ormbr.dml.generator.firebird,
  dbcbr.ddl.generator.firebird,
  dbcbr.metadata.firebird,
  {$ENDIF}
  SysUtils,
  Classes, Infra.DBEngine.Contract;

type
  {$IF DEFINED(USE_FIREDAC)}
  TDatabaseConnectionComponent = TFDConnection;
  {$ELSE}
  TDatabaseConnectionComponent = TSQLConnection;
  {$ENDIF}

  TDatabaseEngineFactory = class(TInterfacedObject, IDbEngineFactory)
  private
    {$IFDEF USE_ORMBR}
    FConnection: IDBConnection;
    FCommandList: TStringList;
    {$ENDIF}
    FDBConnectionComponent: TDatabaseConnectionComponent;
    {$IF NOT (DEFINED(USE_FIREDAC))}
    FTransacao: TDBXTransaction;
    {$ENDIF}
    FInjectedConnection: Boolean;
    FInjectedTransaction: Boolean;
  public
    {$IFDEF USE_ORMBR}
    function Connection: IDBConnection;
    function BuildDatabase: IDbEngineFactory;
    {$ENDIF}
    function ConnectionComponent: Tcomponent;
    function StartTx: IDbEngineFactory;
    function CommitTX: IDbEngineFactory;
    function RollbackTx: IDbEngineFactory;
    function InTransaction: Boolean;
    function InjectConnection(AConn: Tcomponent; ATransactionObject: TObject): IDbEngineFactory;
  public
    constructor Create;
    destructor Destroy; override;

    class function New: IDbEngineFactory;
  end;

implementation

uses
  Infra.SysInfo,
  Infra.DBConfig;

function TDatabaseEngineFactory.CommitTX: IDbEngineFactory;
begin
  Result := Self;
  {$IF DEFINED(USE_FIREDAC)}
  FDBConnectionComponent.Commit;
  {$ELSE}
  if (not FInjectedConnection) and (not FInjectedTransaction) then
    FDBConnectionComponent.DBXConnection.CommitFreeAndNil(FTransacao);
  {$ENDIF}
end;

{$IF DEFINED(USE_ORMBR)}

function TDatabaseEngineFactory.Connection: IDBConnection;
begin
  Result := FConnection;
end;

function TDatabaseEngineFactory.BuildDatabase: IDbEngineFactory;
var
  LManager: IDatabaseCompare;
  LDDL: TDDLCommand;
begin
  FCommandList := TStringList.Create;
  LManager := TModelDbCompare.Create(FConnection);
  LManager.CommandsAutoExecute := True;
  LManager.ComparerFieldPosition := True;
  LManager.BuildDatabase;
  for LDDL in LManager.GetCommandList do
  begin
    FCommandList.Add(LDDL.Command);
  end;
  FCommandList.SaveToFile(Infra.SysInfo.SystemInfo.AppPath + 'build_database.sql');

end;
{$ENDIF}


function TDatabaseEngineFactory.ConnectionComponent: Tcomponent;
begin
  Result := FDBConnectionComponent;
end;

constructor TDatabaseEngineFactory.Create;
begin
  FInjectedConnection := False;
  FInjectedTransaction := False;
  {$IF DEFINED(USE_FIREDAC)}
  FDBConnectionComponent := TFDConnection.Create(nil);
  FDBConnectionComponent.FormatOptions.StrsTrim2Len := True;
  FDBConnectionComponent.DriverName := TDBConfig.Driver;
  FDBConnectionComponent.TxOptions.Isolation := xiReadCommitted;
  FDBConnectionComponent.Params.Add('Database=' + TDBConfig.database);
  FDBConnectionComponent.Params.Add('User_Name=' + TDBConfig.User);
  FDBConnectionComponent.Params.Add('Password=' + TDBConfig.Password);
  FDBConnectionComponent.Params.Add('Protocol=TCPIP');
  FDBConnectionComponent.Params.Add('Port=' + IntToStr(TDBConfig.Port));
  FDBConnectionComponent.Params.Add('Server=' + TDBConfig.Host);
  FDBConnectionComponent.Params.Add('CharacterSet=' + TDBConfig.CharSet);
  FDBConnectionComponent.Params.Add('DriverID=' + TDBConfig.Driver);
  FDBConnectionComponent.Params.Add('OpenMode=OpenOrCreate');
  FDBConnectionComponent.Params.Add('GUIDEndian=Big');
  FDBConnectionComponent.LoginPrompt := False;
  {$IFDEF USE_ORMBR}
  FConnection := TFactoryFireDAC.Create(FDBConnectionComponent, dnFirebird);
  {$ENDIF}
  {$ELSE}
  FDBConnectionComponent := TSQLConnection.Create(nil);
  with FDBConnectionComponent do
  begin
    DriverName := 'Firebird';
    GetDriverFunc := 'getSQLDriverINTERBASE';
    KeepConnection := True;
    LibraryName := 'dbxfb.dll';
    LoginPrompt := False;
    VendorLib := 'fbclient.dll';
    {$IF CompilerVersion <= 21}
    with Params do
    begin
      Clear;
      Add('Database=' + AConfig.DBName);
      Add('Rolename=Rolename');
      Add('User_name=' + AConfig.DBUserName);
      Add('Password=' + AConfig.DBPassword);
      Add('SQLDialect=3');
      Add('ServerCharSet=' + AConfig.DBCharSet);
      Add('Isolationlevel=ReadCommitted');
    end;
    {$ELSE}
    with Params do
    begin
      Clear;
      Add('Database=' + AConfig.DBName);
      Add('Rolename=Rolename');
      Add('User_name=' + AConfig.DBUserName);
      Add('Password=' + AConfig.DBPassword);
      Add('SQLDialect=3');
      Add('ServerCharSet=' + AConfig.DBCharSet);
      Add('Isolationlevel=ReadCommitted');
    end;
    {$IFEND}
    Connected := True;
  end;
  {$IFDEF USE_ORMBR}
  FConnection := TFactoryDBExpress.Create(FDBConnectionComponent, dnFirebird);
  {$ENDIF}
  {$ENDIF}
  {$IFDEF USE_ORMBR}
  if TDBConfig.BuildDatabase then
    BuildDatabase;
  {$ENDIF}
end;

destructor TDatabaseEngineFactory.Destroy;
begin
  {$IF DEFINED(USE_FIREDAC)}
  FDBConnectionComponent.Close;
  FDBConnectionComponent.Free;
  {$ELSE}
  {$ENDIF}
  inherited;
end;

function TDatabaseEngineFactory.InjectConnection(AConn: Tcomponent;
  ATransactionObject: TObject): IDbEngineFactory;
begin
  Result := Self;
  {$IF DEFINED(USE_FIREDAC)}
  if Assigned(FDBConnectionComponent) then
    FreeAndNil(FDBConnectionComponent);
  if not(AConn is TDatabaseConnectionComponent) then
    raise Exception.Create('Componente de conexão inválido.');
  FDBConnectionComponent := TFDConnection(AConn);
  FInjectedConnection := True;
  {$ELSE}
  if Assigned(FDBConnectionComponent) then
    FreeAndNil(FDBConnectionComponent);
  if not(AConn is TDatabaseConnectionComponent) then
    raise Exception.Create('Componente de conexão inválido.');
  FDBConnectionComponent := TSQLConnection(AConn);
  FInjectedConnection := True;
  if Assigned(ATransactionObject) then
  begin
    FTransacao := TDBXTransaction(ATransactionObject);
    FInjectedTransaction := True;
  end;
  {$ENDIF}
end;

function TDatabaseEngineFactory.InTransaction: Boolean;
begin
  {$IF DEFINED(USE_FIREDAC)}
  Result := FDBConnectionComponent.InTransaction;
  {$ELSE}
  Result := Assigned(FTransacao);
  {$ENDIF}
end;

class function TDatabaseEngineFactory.New: IDbEngineFactory;
begin
  Result := Self.Create;
end;

function TDatabaseEngineFactory.RollbackTx: IDbEngineFactory;
begin
  Result := Self;
  {$IF DEFINED(USE_FIREDAC)}
  FDBConnectionComponent.Rollback;
  {$ELSE}
  if (not FInjectedConnection) and (not FInjectedTransaction) then
    FDBConnectionComponent.DBXConnection.RollbackFreeAndNil(FTransacao);
  {$ENDIF}
end;

function TDatabaseEngineFactory.StartTx: IDbEngineFactory;
begin
  Result := Self;
  {$IF DEFINED(USE_FIREDAC)}
  FDBConnectionComponent.StartTransaction;
  {$ELSE}
  if (not FInjectedConnection) and (not FInjectedTransaction) then
    FTransacao := FDBConnectionComponent.DBXConnection.BeginTransaction(TDBXIsolations.ReadCommitted);
  {$ENDIF}
end;

end.
