unit Infra.QueryEngine.DBExpress;

interface
{$IF DEFINED(INFRA_DBEXPRESS)}
uses
  DB,
  Classes, SysUtils,
  SqlExpr, DBclient, Provider,
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
  public
    constructor Create(const AConnection: TDbEngineAbstract); override;
    destructor Destroy; override;

    function Reset: IQueryEngine; override;
    function Clear: IQueryEngine; override;
    function Add(Str: string): IQueryEngine; override;
    function Open: IQueryEngine; override;
    function Exec(const AReturn: Boolean = False): IQueryEngine; override;
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

constructor TQueryEngineDBExpress.Create(
  const AConnection: TDbEngineAbstract);
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

function TQueryEngineDBExpress.DataSet: TDataSet;
begin
  if FClientDataSet.Active then
    Result := FClientDataSet
  else
    Result := FQuery;
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

function TQueryEngineDBExpress.Exec(const AReturn: Boolean = False): IQueryEngine;
begin
  Result := Self;
  try
    FExecutionStartTime := Now;
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Assign(FComandoSQL);
    if FParams.Count > 0 then
      FQuery.Params.Assign(FParams);
    if AReturn then
      FQuery.Open
    else
      FQuery.ExecSQL;
    FExecutionEndTime := Now;
    FRowsAffected := FQuery.RowsAffected;
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao executar Query: ' + FQuery.SQL.Text + sLineBreak +
        'Excessão: ' + E.message);
    end;
  end;
end;

function TQueryEngineDBExpress.FindKey(
  const KeyValues: array of TVarRec): Boolean;
begin
  Result := FClientDataSet.Active and (FClientDataSet.FindKey(KeyValues));
end;

function TQueryEngineDBExpress.IndexFieldNames(
  const Fields: string): IQueryEngine;
begin
  Result := Self;
  FClientDataSet.IndexFieldNames := Fields;
end;

function TQueryEngineDBExpress.IndexFieldNames: string;
begin
  Result := FClientDataSet.IndexFieldNames;	
end;

function TQueryEngineDBExpress.Open: IQueryEngine;
begin
  Result := Self;
  try
    FExecutionStartTime := Now;
    FQuery.Close;
    FClientDataSet.Close;
    FQuery.SQL.Clear;
    if FPaginate and (FRowsPerPage > 0) and (FPage > 0) then
      FDMLGenerator.GenerateSQLPaginating(FPage, FRowsPerPage, FComandoSQL);
    FQuery.SQL.Assign(FComandoSQL);
    if Assigned(FParams) and (FParams.Count > 0) then
      FQuery.Params.Assign(FParams);
    FQuery.Open;
    FClientDataSet.Open;
    FExecutionEndTime := Now;
    if FPaginate then
      FTotalPages := FClientDataSet.FieldByName(FDMLGenerator.GetColumnNameTotalPages).AsInteger;
  except
    on E: Exception do
    begin
      raise;
    end;
  end;
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

function TQueryEngineDBExpress.RetornaAutoIncremento(
  const ASequenceName: string): Integer;
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
    RetornaAutoIncremento(ASequenceName, ATableDest, AFieldDest);
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
