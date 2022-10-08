unit Infra.QueryEngine.Abstract;

interface

uses
  DB, Classes, {$IF DEFINED(INFRA_FIREDAC)}FireDAC.Stan.Param, {$IFEND}
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
  public
    constructor Create(const AConnection: TDbEngineAbstract); virtual;
    destructor Destroy; override;

    function Reset: IQueryEngine; virtual; abstract;
    function Clear: IQueryEngine; virtual; abstract;
    function Add(Str: string): IQueryEngine; virtual; abstract;
    function Open: IQueryEngine; virtual; abstract;
    function Exec(const AReturn: Boolean = False): IQueryEngine; virtual; abstract;
    function Close: IQueryEngine; virtual; abstract;
    function IndexFieldNames(const Fields: string): IQueryEngine; overload; virtual; abstract;
	  function IndexFieldNames: string; overload; virtual; abstract;
    function DataSet: TDataSet; virtual; abstract;
    function ProviderFlags(const FieldName: string; ProviderFlags: TProviderFlags): IQueryEngine; virtual; abstract;
    function ApplyUpdates: Boolean; virtual; abstract;
    function Refresh: Boolean; virtual; abstract;
    function UpdatesPending: Boolean; virtual; abstract;
    function CancelUpdates: IQueryEngine; virtual; abstract;
    function FindKey(const KeyValues: array of TVarRec): Boolean; virtual; abstract;
    function Params: TSQLParams;  virtual; abstract;
    function SQLCommand: string; virtual; abstract;
    function RowsAffected: Integer; virtual; abstract;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload; virtual; abstract;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload; virtual; abstract;
    function Paginate(const APage, ARowsPerPage: Integer): IQueryEngine; virtual;
    function TotalPages: Integer; virtual;
    function DbEngine: TDbEngineAbstract;
    {$IF DEFINED(INFRA_FIREDAC)}
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
  FDbEngine := AConnection;
  FDMLGenerator := TDBDriverRegister.GetDMLGeneratorCommand(AConnection.DbDriver);
end;

function TQueryEngineAbstract.DbEngine: TDbEngineAbstract;
begin
  Result := FDbEngine;
end;

destructor TQueryEngineAbstract.Destroy;
begin

  inherited;
end;

function TQueryEngineAbstract.Paginate(const APage, ARowsPerPage: Integer): IQueryEngine;
begin
  Result := Self;
  FPaginate := True;
  FPage := APage;
  FRowsPerPage := ARowsPerPage;
end;

function TQueryEngineAbstract.TotalPages: Integer;
begin
  Result := FTotalPages;
end;

end.
