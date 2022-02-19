unit Infra.QueryEngine.Contract;

interface

uses
  {$IF DEFINED(INFRA_FIREDAC)}FireDAC.Stan.Param, {$ENDIF}
  DB;

type
  ISQLQuery = interface
    ['{9BBB3764-7029-4B19-87BB-0739BC61C058}']
    function Reset: ISQLQuery;
    function Clear: ISQLQuery;
    function Add(Str: string): ISQLQuery;
    function Open: ISQLQuery;
    function Exec(const AReturn: Boolean = False): ISQLQuery;
    function Close: ISQLQuery;
    function IndexFieldNames(const Fields: string): ISQLQuery;
    function DataSet: TDataSet;
    function ProviderFlags(const FieldName: string; ProviderFlags: TProviderFlags): ISQLQuery;
    function ApplyUpdates: Boolean;
    function Refresh: Boolean;
    function UpdatesPending: Boolean;
    function CancelUpdates: ISQLQuery;
    function FindKey(const KeyValues: array of TVarRec): Boolean;
    function Params: {$IF DEFINED(INFRA_FIREDAC)}TFDParams {$ELSE}TParams{$ENDIF}; overload;
    function SQLCommand: string;
    function RowsAffected: Integer;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload;
  end;

implementation

end.
