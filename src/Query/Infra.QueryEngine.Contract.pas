unit Infra.QueryEngine.Contract;

interface

uses
  {$IF DEFINED(INFRA_FIREDAC)}FireDAC.Stan.Param, {$IFEND}
  {$IF DEFINED(INFRA_ADO)}ADODB, {$IFEND}
  DB, Classes,
  Infra.DBEngine.Abstract;

type
  TSQLParams = {$IF DEFINED(INFRA_FIREDAC)}FireDAC.Stan.Param.TFDParams {$ELSEIF (DEFINED(INFRA_ADO))} TParameters {$ELSE}TParams{$IFEND};

  IQueryEngine = interface
    ['{9BBB3764-7029-4B19-87BB-0739BC61C058}']
    function Reset: IQueryEngine;
    function Clear: IQueryEngine;
    function Add(Str: string): IQueryEngine;
    {$IF DEFINED(INFRA_ADO)}
    function Open(const ATimeout: Integer = 0): IQueryEngine;
    function Exec(const AReturn: Boolean = False; const ATimeout: Integer = 0): IQueryEngine;
    {$ELSE}
    function Open: IQueryEngine;
    function Exec(const AReturn: Boolean = False): IQueryEngine;
    {$ENDIF}
    function Close: IQueryEngine;
    function IndexFieldNames(const Fields: string): IQueryEngine; overload;
    function IndexFieldNames: string; overload;
    function DataSet: TDataSet;
    function ProviderFlags(const FieldName: string; ProviderFlags: TProviderFlags): IQueryEngine;
    function ApplyUpdates: Boolean;
    function Refresh: Boolean;
    function UpdatesPending: Boolean;
    function CancelUpdates: IQueryEngine;
    {$IF DEFINED(INFRA_ZEOS) OR DEFINED(INFRA_ADO)}
    function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean;
    {$ELSE}
    function FindKey(const KeyValues: array of TVarRec): Boolean;
    procedure FindNearest(const AKeyValues: array of const);
    {$IFEND}
    function Params: TSQLParams;
    function FieldDefs: TFieldDefs;
    function SQLCommand: string;
    function SQLCommandParameterized: string;
    function RowsAffected: Integer;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload;
    function Paginate(const APage, ARowsPerPage: Integer): IQueryEngine;
    function TotalPages: Integer;
    {$IF DEFINED(INFRA_FIREDAC) OR DEFINED(INFRA_ZEOS)}
    function SetAutoIncField(const AFieldName: string): IQueryEngine;
    function SetAutoIncGeneratorName(const AGeneratorName: string): IQueryEngine;
    {$IFEND}
    function DBEngine: TDbEngineAbstract;
    function ExecutionStartTime: TDateTime;
    function ExecutionEndTime: TDateTime;
  end;

implementation

end.
