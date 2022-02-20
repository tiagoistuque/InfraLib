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
  {$ENDIF}
  Infra.DBEngine.Contract;

type
  TDbEngineFactory = class abstract(TInterfacedObject, IDbEngineFactory)
  protected
    FDBName: string;
    {$IF DEFINED(INFRA_ORMBR)}
    FDBConnection: IDBConnection;
    {$ENDIF}
  public
    {$IF DEFINED(INFRA_ORMBR)}
    function Connection: IDBConnection;
    function BuildDatabase: IDbEngineFactory;
    {$ENDIF}
    function ConnectionComponent: TComponent; virtual; abstract;
    function Connect: IDbEngineFactory; virtual;
    function ExecSQL(const ASQL: string): IDbEngineFactory; virtual; abstract;
    function ExceSQL(const ASQL: string; var AResultDataSet: TDataSet ): IDbEngineFactory; virtual; abstract;
    function OpenSQL(const ASQL: string; var AResultDataSet: TDataSet ): IDbEngineFactory; virtual; abstract;
    function StartTx: IDbEngineFactory; virtual; abstract;
    function CommitTX: IDbEngineFactory; virtual; abstract;
    function RollbackTx: IDbEngineFactory; virtual; abstract;
    function InTransaction: Boolean; virtual; abstract;
    function InjectConnection(AConn: TComponent; ATransactionObject: TObject): IDbEngineFactory; virtual; abstract;
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

function TDbEngineAbstract.BuildDatabase: IDbEngineFactory;
var
  LManager: IDatabaseCompare;
  LDDL: TDDLCommand;
  LCommandList: TStringList;
begin
  LCommandList := TStringList.Create;
  try
    try
      LManager := TModelDbCompare.Create(FDBConnection);
      LManager.CommandsAutoExecute := True;
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
{$ENDIF}


function TDbEngineFactory.Connect: IDbEngineFactory;
begin
  {$IF DEFINED(INFRA_ORMBR)}
  if Assigned(FDBConnection) then
    FDBConnection.Connect;
  {$ENDIF}
end;

constructor TDbEngineFactory.Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string);
var
  LDBNameExtension: string;
  LDBNameWithoutExtension: string;
begin
  FDBName := ADbConfig.Database;
  if Trim(ASuffixDBName) <> EmptyStr then
  begin
    LDBNameExtension := ExtractFileExt(FDBName);
    LDBNameWithoutExtension := StringReplace(FDBName, LDBNameExtension, '', [rfReplaceAll, rfIgnoreCase]);
    FDBName := LDBNameWithoutExtension + ASuffixDBName + LDBNameExtension;
  end;
end;

destructor TDbEngineFactory.Destroy;
begin

  inherited;
end;

end.
