unit Infra.QueryEngine.Contract;

interface

uses
  {$IF DEFINED(INFRA_FIREDAC)}FireDAC.Stan.Param, {$IFEND}
  DB, Classes,
  Infra.DBEngine.Abstract;

type
  TSQLParams = {$IF DEFINED(INFRA_FIREDAC)}FireDAC.Stan.Param.TFDParams {$ELSE}TParams{$IFEND};

  IQueryEngine = interface
    ['{9BBB3764-7029-4B19-87BB-0739BC61C058}']
    function Reset: IQueryEngine;
    function Clear: IQueryEngine;
    function Add(Str: string): IQueryEngine;
    function Open: IQueryEngine;
    function Exec(const AReturn: Boolean = False): IQueryEngine;
    function Close: IQueryEngine;
    function IndexFieldNames(const Fields: string): IQueryEngine; overload;
	  function IndexFieldNames: string; overload;
    function DataSet: TDataSet;
    function ProviderFlags(const FieldName: string; ProviderFlags: TProviderFlags): IQueryEngine;
    function ApplyUpdates: Boolean;
    function Refresh: Boolean;
    function UpdatesPending: Boolean;
    function CancelUpdates: IQueryEngine;
    function FindKey(const KeyValues: array of TVarRec): Boolean;
    function Params: TSQLParams;
    function SQLCommand: string;
    function RowsAffected: Integer;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload;
    function Paginate(const APage, ARowsPerPage: Integer): IQueryEngine;
    function TotalPages: Integer;
    {$IF DEFINED(INFRA_FIREDAC)}
    function SetAutoIncField(const AFieldName: string): IQueryEngine;
    function SetAutoIncGeneratorName(const AGeneratorName: string): IQueryEngine;
    {$IFEND}
    function DbEngine: TDbEngineAbstract;
  end;

implementation

end.
