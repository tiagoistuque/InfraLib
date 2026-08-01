unit Infra.QueryEngine.DBExpress;

interface
{$IF DEFINED(INFRA_DBEXPRESS)}
uses
  DB,
  Classes, SysUtils,
  SqlExpr, DBClient, Provider,
  Infra.QueryEngine.Abstract,
  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract,
  Infra.QueryEngine.Contract;

type

  TQueryEngineDBExpress = class(TQueryEngineAbstract)
  private
    FQuery: TSQLQuery;
    FClientDataSet: TClientDataSet;
    FProvider: TDataSetProvider;
    FParams: TSQLParams;
    FRowsAffected: Integer;
  protected
    // Implementação dos ganchos (hooks) do Template Method da classe abstrata
    procedure PrepareComponentSQLAndParams; override;
    procedure InternalOpen; override;
    function InternalExec(const AReturn: Boolean): Integer; override;
    function InternalGetTotalPages: Integer; override;
  public
    constructor Create(const AConnection: TDbEngineAbstract); override;
    destructor Destroy; override;

    function Reset: IQueryEngine; override;
    function Clear: IQueryEngine; override;
    function Add(Str: string): IQueryEngine; override;
    function Close: IQueryEngine; override;
    function IndexFieldNames(const Fields: string): IQueryEngine; override;
    function IndexFieldNames: string; override;
    function DataSet: TDataSet; override;
    function ProviderFlags(const FieldName: string; ProviderFlags: TProviderFlags): IQueryEngine; override;
    function ApplyUpdates: Boolean; override;
    function Refresh: Boolean; override;
    function UpdatesPending: Boolean; override;
    function CancelUpdates: IQueryEngine; override;
    function FindKey(const KeyValues: array of TVarRec): Boolean; override;
    function Params: TSQLParams; override;
    function TotalPages: Integer; override;
    function RowsAffected: Integer; override;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload; override;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload; override;
  end;
{$IFEND}
implementation
{$IF DEFINED(INFRA_DBEXPRESS)}
var
  DM: TDataModule;

{ TQueryEngineDBExpress }

constructor TQueryEngineDBExpress.Create(const AConnection: TDbEngineAbstract);
begin
  inherited;
  FQuery := TSQLQuery.Create(DM);
  FQuery.SQLConnection := TSQLConnection(AConnection.ConnectionComponent);

  FProvider := TDataSetProvider.Create(DM);
  FProvider.Options := [poUseQuoteChar];
  FProvider.UpdateMode := upWhereKeyOnly;

  FClientDataSet := TClientDataSet.Create(DM);
  FProvider.DataSet := FQuery;
  Sleep(1);
  FProvider.Name := 'InfraDSP' + Format('%s%d',[FormatDateTime('YYYYMMDDHHNNSSZZZ', Now), Random(32768)]);
  FClientDataSet.ProviderName := FProvider.Name;

  FParams := TSQLParams.Create;
end;

destructor TQueryEngineDBExpress.Destroy;
begin
  FParams.Free;
  FClientDataSet.Free;
  FProvider.Free;
  FQuery.Close;
  FQuery.Free;
  inherited;
end;

// --- IMPLEMENTAÇÃO DOS MÉTODOS DO TEMPLATE METHOD ---

procedure TQueryEngineDBExpress.PrepareComponentSQLAndParams;
begin
  FQuery.Close;
  FClientDataSet.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Assign(FComandoSQL);

  if Assigned(FParams) and (FParams.Count > 0) then
    FQuery.Params.Assign(FParams);
end;

procedure TQueryEngineDBExpress.InternalOpen;
begin
  FQuery.Open;
  FClientDataSet.Open;
end;

function TQueryEngineDBExpress.InternalExec(const AReturn: Boolean): Integer;
begin
  if AReturn then
    FQuery.Open
  else
    FQuery.ExecSQL;

  Result := FQuery.RowsAffected;
end;

function TQueryEngineDBExpress.InternalGetTotalPages: Integer;
begin
  Result := FClientDataSet.FieldByName(FDMLGenerator.GetColumnNameTotalPages).AsInteger;
end;

// --- DEMAIS MÉTODOS DE COMPORTAMENTO ---

function TQueryEngineDBExpress.Add(Str: string): IQueryEngine;
begin
  Result := Self;
  FComandoSQL.Add(Str);
end;

function TQueryEngineDBExpress.ApplyUpdates: Boolean;
begin
  Result := FClientDataSet.ApplyUpdates(0) = 0;
end;

function TQueryEngineDBExpress.CancelUpdates: IQueryEngine;
begin
  Result := Self;
  if FClientDataSet.Active then
    FClientDataSet.CancelUpdates;
end;

function TQueryEngineDBExpress.Clear: IQueryEngine;
begin
  Result := Self;
  FParams.Clear;
  FQuery.SQL.Clear;
  FComandoSQL.Clear;
end;

function TQueryEngineDBExpress.Close: IQueryEngine;
begin
  Result := Self;
  FClientDataSet.Close;
  FClientDataSet.Params.Clear;
  FQuery.Params.Clear;
  FQuery.Close;
end;

function TQueryEngineDBExpress.DataSet: TDataSet;
begin
  if FClientDataSet.Active then
    Result := FClientDataSet
  else
    Result := FQuery;
end;

function TQueryEngineDBExpress.FindKey(const KeyValues: array of TVarRec): Boolean;
begin
  Result := FClientDataSet.Active and (FClientDataSet.FindKey(KeyValues));
end;

function TQueryEngineDBExpress.IndexFieldNames(const Fields: string): IQueryEngine;
begin
  Result := Self;
  FClientDataSet.IndexFieldNames := Fields;
end;

function TQueryEngineDBExpress.IndexFieldNames: string;
begin
  Result := FClientDataSet.IndexFieldNames;
end;

function TQueryEngineDBExpress.Params: TSQLParams;
begin
  if (Pos(':', FComandoSQL.Text) > 0) and (FParams.Count = 0) then
  begin
    FParams.Clear;
    FParams.ParseSQL(FComandoSQL.Text, True);
  end;
  Result := FParams;
end;

function TQueryEngineDBExpress.ProviderFlags(const FieldName: string;
  ProviderFlags: TProviderFlags): IQueryEngine;
begin
  Result := Self;
  FClientDataSet.FieldByName(FieldName).ProviderFlags := ProviderFlags;
  FQuery.FieldByName(FieldName).ProviderFlags := ProviderFlags;
end;

function TQueryEngineDBExpress.Refresh: Boolean;
begin
  FClientDataSet.Refresh;
  Result := True;
end;

function TQueryEngineDBExpress.Reset: IQueryEngine;
begin
  Result := Self;
  Close.Clear;
end;

function TQueryEngineDBExpress.RetornaAutoIncremento(const ASequenceName: string): Integer;
begin
  Self.Reset
    .Add('SELECT GEN_ID(' + ASequenceName + ',1) AS CONTROLE FROM RDB$DATABASE');
  Result := Self.Open.DataSet.FieldByName('CONTROLE').AsInteger;
end;

function TQueryEngineDBExpress.RetornaAutoIncremento(const ASequenceName,
  ATableDest, AFieldDest: string): Integer;
begin
  Result := Self.RetornaAutoIncremento(ASequenceName);
  Self.Reset
    .Add('SELECT COUNT(*) AS QTDE')
    .Add('FROM ' + ATableDest)
    .Add('WHERE ' + AFieldDest + ' = :FIELDVALUE');
  Self.Params.ParamByName('FIELDVALUE').AsInteger := Result;

  if Self.Open.DataSet.FieldByName('QTDE').AsInteger > 0 then
  begin
    // CORREÇÃO DO BUG: Atribuindo corretamente o retorno da chamada recursiva ao Result
    Result := RetornaAutoIncremento(ASequenceName, ATableDest, AFieldDest);
  end;
end;

function TQueryEngineDBExpress.RowsAffected: Integer;
begin
  Result := FRowsAffected;
end;

function TQueryEngineDBExpress.TotalPages: Integer;
begin
  Result := FTotalPages;
end;

function TQueryEngineDBExpress.UpdatesPending: Boolean;
begin
  Result := FClientDataSet.Active and (FClientDataSet.ChangeCount > 0);
end;

initialization

DM := TDataModule.Create(nil);
Randomize;

finalization

DM.Free;
{$IFEND}
end.
