unit Infra.QueryEngine.Abstract;

interface

uses
  DB, {$IF DEFINED(INFRA_FIREDAC)}FireDAC.Stan.Param, {$IFEND}
  Infra.DBEngine.Contract,
  Infra.QueryEngine.Contract;

type

  TQueryEngineFactory = class abstract(TInterfacedObject, ISQLQuery)
  protected
    FDbEngine: IDbEngineFactory;
  public
    constructor Create(const AConnection: IDbEngineFactory); virtual;
    destructor Destroy; override;

    function Reset: ISQLQuery; virtual; abstract;
    function Clear: ISQLQuery; virtual; abstract;
    function Add(Str: string): ISQLQuery; virtual; abstract;
    function Open: ISQLQuery; virtual; abstract;
    function Exec(const AReturn: Boolean = False): ISQLQuery; virtual; abstract;
    function Close: ISQLQuery; virtual; abstract;
    function IndexFieldNames(const Fields: string): ISQLQuery; virtual; abstract;
	function IndexFieldNames: string; virtual; abstract;
    function DataSet: TDataSet; virtual; abstract;
    function ProviderFlags(const FieldName: string; ProviderFlags: TProviderFlags): ISQLQuery; virtual; abstract;
    function ApplyUpdates: Boolean; virtual; abstract;
    function Refresh: Boolean; virtual; abstract;
    function UpdatesPending: Boolean; virtual; abstract;
    function CancelUpdates: ISQLQuery; virtual; abstract;
    function FindKey(const KeyValues: array of TVarRec): Boolean; virtual; abstract;
    function Params: TSQLParams;  virtual; abstract;
    function SQLCommand: string; virtual; abstract;
    function RowsAffected: Integer; virtual; abstract;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload; virtual; abstract;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload; virtual; abstract;
  end;

implementation

{ TQueryEngineFActory }

constructor TQueryEngineFActory.Create(
  const AConnection: IDbEngineFactory);
begin
  FDbEngine := AConnection;
end;

destructor TQueryEngineFActory.Destroy;
begin

  inherited;
end;

end.
