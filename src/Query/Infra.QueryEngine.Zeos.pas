unit Infra.QueryEngine.Zeos;

interface

{$IF DEFINED(INFRA_ZEOS)}


uses
  DB,
  Classes,
  SysUtils,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZAbstractConnection,
  ZConnection,
  ZSequence,
  Infra.QueryEngine.Abstract,
  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract,
  Infra.QueryEngine.Contract;

type

  TQueryEngineZeos = class(TQueryEngineAbstract)
  private
    FQuery: TZQuery;
    FParams: TSQLParams;
    FZSequence: TZSequence;
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
    function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean; override;
    function Params: TSQLParams; override;
    function TotalPages: Integer; override;
    function RowsAffected: Integer; override;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload; override;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload; override;
    function SetAutoIncField(const AFieldName: string): IQueryEngine; override;
    function SetAutoIncGeneratorName(const AGeneratorName: string): IQueryEngine; override;
  end;
{$IFEND}

implementation

{$IF DEFINED(INFRA_ZEOS)}
{ TQueryEngineZeos }

constructor TQueryEngineZeos.Create(const AConnection: TDbEngineAbstract);
begin
  inherited;
  FQuery := TZQuery.Create(nil);
  FQuery.Connection := TZConnection(AConnection.ConnectionComponent);
  FQuery.CachedUpdates := True;
  FParams := TSQLParams.Create;
  FZSequence := TZSequence.Create(nil);
  FZSequence.Connection := TZConnection(AConnection.ConnectionComponent);
  FQuery.Sequence := FZSequence;
end;

destructor TQueryEngineZeos.Destroy;
begin
  FQuery.Close;
  FQuery.Free;
  FParams.Free;
  inherited;
end;

// --- IMPLEMENTAÇÃO DOS MÉTODOS DO TEMPLATE METHOD ---

procedure TQueryEngineZeos.PrepareComponentSQLAndParams;
begin
  FQuery.Close;
  FQuery.IndexFieldNames := EmptyStr;
  FQuery.SQL.Clear;
  FQuery.SQL.Assign(FComandoSQL);

  if FParams.Count > 0 then
    FQuery.Params.Assign(FParams);
end;

procedure TQueryEngineZeos.InternalOpen;
begin
  FQuery.Open;
end;

function TQueryEngineZeos.InternalExec(const AReturn: Boolean): Integer;
begin
  if AReturn then
    FQuery.Open
  else
    FQuery.ExecSQL;

  Result := FQuery.RowsAffected;
end;

function TQueryEngineZeos.InternalGetTotalPages: Integer;
begin
  Result := FQuery.FieldByName(FDMLGenerator.GetColumnNameTotalPages).AsInteger;
end;

// --- DEMAIS MÉTODOS DE COMPORTAMENTO ---

function TQueryEngineZeos.Add(Str: string): IQueryEngine;
begin
  Result := Self;
  FComandoSQL.Add(Str);
end;

function TQueryEngineZeos.ApplyUpdates: Boolean;
begin
  FQuery.ApplyUpdates;
  Result := True;
end;

function TQueryEngineZeos.CancelUpdates: IQueryEngine;
begin
  Result := Self;
  if FQuery.Active then
    FQuery.CancelUpdates;
end;

function TQueryEngineZeos.Clear: IQueryEngine;
begin
  Result := Self;
  FParams.Clear;
  FQuery.SQL.Clear;
  FComandoSQL.Clear;
end;

function TQueryEngineZeos.Close: IQueryEngine;
begin
  Result := Self;
  FQuery.Close;
end;

function TQueryEngineZeos.DataSet: TDataSet;
begin
  Result := FQuery;
end;

function TQueryEngineZeos.IndexFieldNames(const Fields: string): IQueryEngine;
begin
  Result := Self;
  FQuery.IndexFieldNames := Fields;
end;

function TQueryEngineZeos.IndexFieldNames: string;
begin
  Result := FQuery.IndexFieldNames;
end;

function TQueryEngineZeos.Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean;
begin
  Result := FQuery.Locate(KeyFields, KeyValues, Options);
end;

function TQueryEngineZeos.Params: TSQLParams;
begin
  if (Pos(':', FComandoSQL.Text) > 0) and (FParams.Count = 0) then
  begin
    FParams.Clear;
    FParams.ParseSQL(FComandoSQL.Text, True);
  end;
  Result := FParams;
end;

function TQueryEngineZeos.ProviderFlags(const FieldName: string;
  ProviderFlags: TProviderFlags): IQueryEngine;
begin
  Result := Self;
  FQuery.FieldByName(FieldName).ProviderFlags := ProviderFlags;
end;

function TQueryEngineZeos.Refresh: Boolean;
begin
  FQuery.Refresh;
  Result := True;
end;

function TQueryEngineZeos.Reset: IQueryEngine;
begin
  Result := Self;
  FZSequence.SequenceName := '';
  FQuery.SequenceField := '';
  Close.Clear;
end;

function TQueryEngineZeos.RetornaAutoIncremento(const ASequenceName: string): Integer;
begin
  Self.Reset
    .Add('SELECT GEN_ID(' + ASequenceName + ',1) AS CONTROLE FROM RDB$DATABASE');
  Result := Self.Open.DataSet.FieldByName('CONTROLE').AsInteger;
end;

function TQueryEngineZeos.RetornaAutoIncremento(const ASequenceName,
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
    // CORREÇÃO DO BUG: Vinculando o retorno recursivo à variável Result da função
    Result := RetornaAutoIncremento(ASequenceName, ATableDest, AFieldDest);
  end;
end;

function TQueryEngineZeos.RowsAffected: Integer;
begin
  Result := FRowsAffected;
end;

function TQueryEngineZeos.SetAutoIncField(const AFieldName: string): IQueryEngine;
begin
  Result := Self;
  FQuery.SequenceField := AFieldName;
end;

function TQueryEngineZeos.SetAutoIncGeneratorName(const AGeneratorName: string): IQueryEngine;
begin
  Result := Self;
  FZSequence.SequenceName := AGeneratorName;
end;

function TQueryEngineZeos.TotalPages: Integer;
begin
  Result := FTotalPages;
end;

function TQueryEngineZeos.UpdatesPending: Boolean;
begin
  Result := FQuery.Active and (FQuery.UpdatesPending);
end;
{$IFEND}

end.
