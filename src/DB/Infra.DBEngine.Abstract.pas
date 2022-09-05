unit Infra.DBEngine.Abstract;

interface

uses
  Classes,
  SysUtils,
  DB,
  {$IF DEFINED(INFRA_ORMBR)}
  dbebr.factory.interfaces,
  dbcbr.ddl.commands,
  dbcbr.database.compare,
  dbcbr.metadata.DB.factory,
  dbcbr.database.interfaces,
  ormbr.modeldb.compare,
  ormbr.metadata.classe.factory,
  {$IFEND}
  Infra.DBEngine.Contract;

type
  TDbEngineAbstract = class abstract(TInterfacedObject, IDbEngine)
  protected
    FDBName: string;
    FAutoExcuteMigrations: Boolean;
    FDbDriver: TDBDriver;
    {$IF DEFINED(INFRA_ORMBR)}
    FDBConnection: IDBConnection;
    {$IFEND}
  public
    {$IF DEFINED(INFRA_ORMBR)}
    function Connection: IDBConnection;
    procedure ExecuteMigrations;
    {$IFEND}
    function ConnectionComponent: TComponent; virtual; abstract;
    procedure Connect; virtual;
    procedure Disconnect; virtual;
    function ExecSQL(const ASQL: string): Integer; virtual; abstract;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet ): Integer; virtual; abstract;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet ): Integer; overload; virtual; abstract;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet; const APage: Integer; const ARowsPerPage: Integer): Integer; overload; virtual; abstract;
    procedure StartTx; virtual; abstract;
    procedure CommitTX; virtual; abstract;
    procedure RollbackTx; virtual; abstract;
    function InTransaction: Boolean; virtual; abstract;
    function IsConnected: Boolean; virtual; abstract;
    function RowsAffected: Integer; virtual; abstract;
    procedure InjectConnection(AConn: TComponent; ATransactionObject: TObject); virtual; abstract;
    function DbDriver: TDBDriver; virtual;
  public
    constructor Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''); virtual;
    destructor Destroy; override;

  end;

implementation

uses
  Infra.SysInfo;

{$IF DEFINED(INFRA_ORMBR)}

function TDbEngineAbstract.Connection: IDBConnection;
begin
  Result := FDBConnection;
end;

procedure TDbEngineAbstract.ExecuteMigrations;
var
  LManager: IDatabaseCompare;
  LDDL: TDDLCommand;
  LCommandList: TStringList;
begin
  LCommandList := TStringList.Create;
  try
    try
      LManager := TModelDbCompare.Create(FDBConnection);
      LManager.CommandsAutoExecute := FAutoExcuteMigrations;
      LManager.ComparerFieldPosition := True;
      LManager.BuildDatabase;
      for LDDL in LManager.GetCommandList do
      begin
        LCommandList.Add(LDDL.Command);
      end;
    except
      on E: Exception do
      begin
        LCommandList.Add(E.Message);
        raise;
      end;
    end;
  finally
    if LCommandList.Count > 0 then
      LCommandList.SaveToFile(SystemInfo.AppPath + Format('%s_migration.sql', [FormatDatetime('yyyymmdd-hhnnsszzz', Now)]));
    LCommandList.Free;
  end;
end;
{$IFEND}


procedure TDbEngineAbstract.Connect;
begin
  {$IF DEFINED(INFRA_ORMBR)}
  if Assigned(FDBConnection) then
    FDBConnection.Connect;
  {$IFEND}
end;

constructor TDbEngineAbstract.Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string);
var
  LDBNameExtension: string;
  LDBNameWithoutExtension: string;
begin
  FAutoExcuteMigrations := False;
  if Assigned(ADbConfig) then
  begin
    FDbDriver := ADbConfig.Driver;
    FAutoExcuteMigrations := ADbConfig.GetExecuteMigrations;
    FDBName := ADbConfig.Database;
    if Trim(ASuffixDBName) <> EmptyStr then
    begin
      LDBNameExtension := ExtractFileExt(FDBName);
      LDBNameWithoutExtension := StringReplace(FDBName, LDBNameExtension, '', [rfReplaceAll, rfIgnoreCase]);
      FDBName := LDBNameWithoutExtension + ASuffixDBName + LDBNameExtension;
    end;
  end;
end;

function TDbEngineAbstract.DbDriver: TDBDriver;
begin
  Result := FDbDriver;
end;

destructor TDbEngineAbstract.Destroy;
begin

  inherited;
end;

procedure TDbEngineAbstract.Disconnect;
begin
  {$IF DEFINED(INFRA_ORMBR)}
  if Assigned(FDBConnection) then
    FDBConnection.Disconnect;
  {$IFEND}
end;

end.
