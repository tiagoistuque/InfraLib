unit Infra.QueryEngine.Abstract;

interface

uses
  DB, Classes, {$IF DEFINED(INFRA_FIREDAC)}FireDAC.Stan.Param, {$IFEND}
  Infra.DBEngine.Contract,
  Infra.DBEngine.Abstract,
  Infra.QueryEngine.Contract,
  Infra.DML.Contracts;

type

  TQueryEngineAbstract = class abstract(TInterfacedObject, ISQLQuery)
  protected
    FDbEngine: TDbEngineAbstract;
    FDMLGenerator: IDMLGeneratorCommand;
    FPaginate: Boolean;
    FPage: Integer;
    FRowsPerPage: Integer;
    FTotalPages: Integer;
  public
    constructor Create(const AConnection: TDbEngineAbstract); virtual;
    destructor Destroy; override;

    function Reset: ISQLQuery; virtual; abstract;
    function Clear: ISQLQuery; virtual; abstract;
    function Add(Str: string): ISQLQuery; virtual; abstract;
    function Open: ISQLQuery; virtual; abstract;
    function Exec(const AReturn: Boolean = False): ISQLQuery; virtual; abstract;
    function Close: ISQLQuery; virtual; abstract;
    function IndexFieldNames(const Fields: string): ISQLQuery; overload; virtual; abstract;
	  function IndexFieldNames: string; overload; virtual; abstract;
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
    function Paginate(const APage, ARowsPerPage: Integer): ISQLQuery; virtual;
    function TotalPages: Integer; virtual; abstract;
    function DbEngine: TDbEngineAbstract;
    function SetAutoIncField(const AFieldName: string): ISQLQuery; virtual; abstract;
    function SetAutoIncGeneratorName(const AGeneratorName: string): ISQLQuery; virtual; abstract;
  end;

implementation

{ TQueryEngineFActory }

uses Infra.DBDriver.Register;

constructor TQueryEngineAbstract.Create(
  const AConnection: TDbEngineAbstract);
begin
  FDbEngine := AConnection;
  FDMLGenerator := TDBDriverRegister.GetDriver(AConnection.DbDriver);
end;

function TQueryEngineAbstract.DbEngine: TDbEngineAbstract;
begin
  Result := FDbEngine;
end;

destructor TQueryEngineAbstract.Destroy;
begin

  inherited;
end;

function TQueryEngineAbstract.Paginate(const APage, ARowsPerPage: Integer): ISQLQuery;
begin
  Result := Self;
  FPaginate := True;
  FPage := APage;
  FRowsPerPage := ARowsPerPage;
end;

end.
