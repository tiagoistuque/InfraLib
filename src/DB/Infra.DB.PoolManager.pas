unit Infra.DB.PoolManager;

interface

uses
  DB,
  SysUtils,
  dbebr.factory.interfaces,
  Infra.PoolManager,
  Infra.DBEngine,
  Infra.DBEngine.Abstract;

type

  TQueryCallback = reference to procedure(AQuery: IDBQuery);
  TConnectionCallback = reference to procedure(AConnection: TDbEngineAbstract);

  TDBEnginePoolManager = class(TPoolManager<TDbEngineAbstract>)
  private
    class var FDefaultFDConnectionPoolManager: TDBEnginePoolManager;
  protected
    class procedure CreateDefaultInstance;
    class function GetDefaultFDConnectionPoolManager: TDBEnginePoolManager; static;
  public
    procedure DoGetInstance(var AInstance: TDbEngineAbstract; var AInstanceOwner: Boolean); override;
    procedure ExecSQL(const ASQL: string = '');
    procedure Query(AQueryCallback: TQueryCallback);
    procedure Connection(AConnectionCallback: TConnectionCallback);
    class constructor Initialize;
    class destructor UnInitialize;
    class property DefaultManager: TDBEnginePoolManager read GetDefaultFDConnectionPoolManager;
  end;

implementation

uses
  Infra.DBConfig,
  SyncObjs;

{ TFDConnectionPoolManager }

procedure TDBEnginePoolManager.Connection(AConnectionCallback: TConnectionCallback);
var
  LItem: TPoolItem<TDbEngineAbstract>;
  LConnection: TDbEngineAbstract;
begin
  LItem := TDBEnginePoolManager.DefaultManager.TryGetItem;
  LConnection := LItem.Acquire;
  try
    AConnectionCallback(LConnection);
  finally
    LItem.Release;
  end;
end;

class procedure TDBEnginePoolManager.CreateDefaultInstance;
begin
  FDefaultFDConnectionPoolManager := TDBEnginePoolManager.Create(True);
  FDefaultFDConnectionPoolManager.SetMaxIdleSeconds(60);
  FDefaultFDConnectionPoolManager.Start;
end;

procedure TDBEnginePoolManager.DoGetInstance(var AInstance: TDbEngineAbstract; var AInstanceOwner: Boolean);
begin
  inherited;
  AInstanceOwner := True;
  AInstance := TDBEngine.Create(TDBConfig.New('OAUTH2_'));
  try
    AInstance.Connection.Connect;
  except
    raise;
  end;
end;

procedure TDBEnginePoolManager.ExecSQL(const ASQL: string);
var
  LItem: TPoolItem<TDbEngineAbstract>;
  LConnection: TDbEngineAbstract;
begin
  LItem := TDBEnginePoolManager.DefaultManager.TryGetItem;
  LConnection := LItem.Acquire;
  try
    LConnection.Connection.ExecuteDirect(ASQL);
  finally
    LItem.Release;
  end;
end;

class function TDBEnginePoolManager.GetDefaultFDConnectionPoolManager: TDBEnginePoolManager;
begin
  if (FDefaultFDConnectionPoolManager = nil) then
  begin
    CreateDefaultInstance;
  end;
  Result := FDefaultFDConnectionPoolManager;
end;

class constructor TDBEnginePoolManager.Initialize;
begin
  CreateDefaultInstance;
end;

procedure TDBEnginePoolManager.Query(AQueryCallback: TQueryCallback);
var
  LItem: TPoolItem<TDbEngineAbstract>;
  LConnection: TDbEngineAbstract;
  LQuery: IDBQuery;
begin
  LItem := TDBEnginePoolManager.DefaultManager.TryGetItem;
  LConnection := LItem.Acquire;
  try
    LQuery := LConnection.Connection.CreateQuery;
    AQueryCallback(LQuery);
  finally
    LItem.Release;
  end;
end;

class destructor TDBEnginePoolManager.UnInitialize;
begin
  if FDefaultFDConnectionPoolManager <> nil then
  begin
    FDefaultFDConnectionPoolManager.Free;
  end;
end;

end.
