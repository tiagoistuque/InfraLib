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
  dbcbr.ddl.generator.firebird,
  dbcbr.metadata.firebird,

  ormbr.modeldb.compare,
  ormbr.metadata.classe.factory,
  ormbr.dml.generator.firebird,
  {$IFEND}
  Infra.DBEngine.Contract;

type
  TDbEngineAbstract = class abstract
  protected
    FDBName: string;
    FAutoExcuteMigrations: Boolean;
    {$IF DEFINED(INFRA_ORMBR)}
    FDBConnection: IDBConnection;
    {$IFEND}
  public
    {$IF DEFINED(INFRA_ORMBR)}
    function Connection: IDBConnection;
    function ExecuteMigrations: TDbEngineAbstract;
    {$IFEND}
    function ConnectionComponent: TComponent; virtual; abstract;
    function Connect: TDbEngineAbstract; virtual;
    function Disconnect: TDbEngineAbstract; virtual;
    function ExecSQL(const ASQL: string): TDbEngineAbstract; virtual; abstract;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet ): TDbEngineAbstract; virtual; abstract;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet ): TDbEngineAbstract; virtual; abstract;
    function StartTx: TDbEngineAbstract; virtual; abstract;
    function CommitTX: TDbEngineAbstract; virtual; abstract;
    function RollbackTx: TDbEngineAbstract; virtual; abstract;
    function InTransaction: Boolean; virtual; abstract;
    function IsConnected: Boolean; virtual; abstract;
    function RowsAffected: Integer; virtual; abstract;
    function InjectConnection(AConn: TComponent; ATransactionObject: TObject): TDbEngineAbstract; virtual; abstract;
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

function TDbEngineAbstract.ExecuteMigrations: TDbEngineAbstract;
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


function TDbEngineAbstract.Connect: TDbEngineAbstract;
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

destructor TDbEngineAbstract.Destroy;
begin

  inherited;
end;

function TDbEngineAbstract.Disconnect: TDbEngineAbstract;
begin
  {$IF DEFINED(INFRA_ORMBR)}
  if Assigned(FDBConnection) then
    FDBConnection.Disconnect;
  {$IFEND}
end;

end.
