unit Infra.QueryEngine.Abstract;

interface

uses
  DB, Classes, SysUtils, StrUtils,
  {$IF DEFINED(INFRA_FIREDAC)}FireDAC.Stan.Param, {$IFEND}
  {$IF DEFINED(INFRA_ADO)}ADODB, {$IFEND}
  Infra.DBEngine.Contract,
  Infra.DBEngine.Abstract,
  Infra.QueryEngine.Contract,
  Infra.DML.Contracts;

type

  TQueryEngineAbstract = class abstract(TInterfacedObject, IQueryEngine)
  protected
    FDbEngine: TDbEngineAbstract;
    FDMLGenerator: IDMLGeneratorCommand;
    FPaginate: Boolean;
    FPage: Integer;
    FRowsPerPage: Integer;
    FTotalPages: Integer;
    FExecutionStartTime: TDateTime;
    FExecutionEndTime: TDateTime;
    FComandoSQL: TStringList;
  public
    constructor Create(const AConnection: TDbEngineAbstract); virtual;
    destructor Destroy; override;

    function Reset: IQueryEngine; virtual; abstract;
    function Clear: IQueryEngine; virtual; abstract;
    function Add(Str: string): IQueryEngine; virtual; abstract;
    {$IF DEFINED(INFRA_ADO)}
    function Open(const ATimeout: Integer = 0): IQueryEngine; virtual; abstract;
    function Exec(const AReturn: Boolean = False; const ATimeout: Integer = 0): IQueryEngine; virtual; abstract;
    {$ELSE}
    function Open: IQueryEngine; virtual; abstract;
    function Exec(const AReturn: Boolean = False): IQueryEngine; virtual; abstract;
    {$ENDIF}
    function Close: IQueryEngine; virtual; abstract;
    function IndexFieldNames(const Fields: string): IQueryEngine; overload; virtual; abstract;
    function IndexFieldNames: string; overload; virtual; abstract;
    function DataSet: TDataSet; virtual; abstract;
    function ProviderFlags(const FieldName: string; ProviderFlags: TProviderFlags): IQueryEngine; virtual; abstract;
    function ApplyUpdates: Boolean; virtual; abstract;
    function Refresh: Boolean; virtual; abstract;
    function UpdatesPending: Boolean; virtual; abstract;
    function CancelUpdates: IQueryEngine; virtual; abstract;
    {$IF DEFINED(INFRA_ZEOS) OR DEFINED(INFRA_ADO)}
    function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean; virtual; abstract;
    {$ELSE}
    function FindKey(const KeyValues: array of TVarRec): Boolean; virtual; abstract;
    procedure FindNearest(const AKeyValues: array of const); virtual; abstract;
    {$IFEND}
    function Params: TSQLParams; virtual; abstract;
    function FieldDefs: TFieldDefs; virtual; abstract;
    function SQLCommand: string; virtual;
    function SQLCommandParameterized: string; virtual;
    function RowsAffected: Integer; virtual; abstract;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload; virtual; abstract;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload; virtual; abstract;
    function Paginate(const APage, ARowsPerPage: Integer): IQueryEngine; virtual;
    function TotalPages: Integer; virtual;
    function DBEngine: TDbEngineAbstract;
    function ExecutionStartTime: TDateTime; virtual;
    function ExecutionEndTime: TDateTime; virtual;
    {$IF DEFINED(INFRA_FIREDAC) OR DEFINED(INFRA_ZEOS)}
    function SetAutoIncField(const AFieldName: string): IQueryEngine; virtual; abstract;
    function SetAutoIncGeneratorName(const AGeneratorName: string): IQueryEngine; virtual; abstract;
    {$IFEND}
  end;

implementation

{ TQueryEngineFActory }

uses Infra.DBDriver.Register;

constructor TQueryEngineAbstract.Create(
  const AConnection: TDbEngineAbstract);
begin
  FComandoSQL := TStringList.Create;
  FDbEngine := AConnection;
  FDMLGenerator := TDBDriverRegister.GetDMLGeneratorCommand(AConnection.DBDriver);
end;

function TQueryEngineAbstract.DBEngine: TDbEngineAbstract;
begin
  Result := FDbEngine;
end;

destructor TQueryEngineAbstract.Destroy;
begin
  FComandoSQL.Free;
  inherited;
end;

function TQueryEngineAbstract.ExecutionStartTime: TDateTime;
begin
  Result := FExecutionStartTime;
end;

function TQueryEngineAbstract.ExecutionEndTime: TDateTime;
begin
  Result := FExecutionEndTime;
end;

function TQueryEngineAbstract.Paginate(const APage, ARowsPerPage: Integer): IQueryEngine;
begin
  Result := Self;
  FPaginate := True;
  FPage := APage;
  FRowsPerPage := ARowsPerPage;
end;

function TQueryEngineAbstract.SQLCommand: string;
var
  i: Integer;
  LParamValue: string;
  LValueString: string;
begin
  Result := FComandoSQL.Text;
  for i := 0 to Params.Count - 1 do
  begin
    {$IF DEFINED(INFRA_ADO)}
    LValueString := Params.Items[i].Value;
    {$ELSE}
    LValueString := Params.Items[i].AsString;
    {$IFEND}
    case Params.Items[i].DataType of
      ftString, ftWideString, ftDate, ftDateTime, ftTime, ftTimeStamp, ftTimeStampOffset:
        LParamValue := QuotedStr(LValueString);
    else
      LParamValue := LValueString;
    end;
    Result := StringReplace(Result, ':' + Params.Items[i].Name, LParamValue, []);
  end;
end;

function TQueryEngineAbstract.SQLCommandParameterized: string;
begin
  Result := FComandoSQL.Text;
end;

function TQueryEngineAbstract.TotalPages: Integer;
begin
  Result := FTotalPages;
end;

end.
