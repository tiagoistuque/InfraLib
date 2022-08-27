unit Infra.QueryEngine.FireDAC;

interface

{$IF DEFINED(INFRA_FIREDAC)}

uses
  DB,
  Classes, SysUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.Util,
  Infra.QueryEngine.Abstract,
  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract,
  Infra.QueryEngine.Contract;

type

  TQueryEngineFireDAC = class(TQueryEngineAbstract)
  private
    FQuery: TFDQuery;
    FParams: TSQLParams;
    FComandoSQL: TStringList;
    FRowsAffected: Integer;
  public
    constructor Create(const AConnection: TDbEngineAbstract); override;
    destructor Destroy; override;

    function Reset: ISQLQuery; override;
    function Clear: ISQLQuery; override;
    function Add(Str: string): ISQLQuery; override;
    function Open: ISQLQuery; override;
    function Exec(const AReturn: Boolean = False): ISQLQuery; override;
    function Close: ISQLQuery; override;
    function IndexFieldNames(const Fields: string): ISQLQuery; override;
    function IndexFieldNames: string; override;
    function DataSet: TDataSet; override;
    function ProviderFlags(const FieldName: string; ProviderFlags: TProviderFlags): ISQLQuery; override;
    function ApplyUpdates: Boolean; override;
    function Refresh: Boolean; override;
    function UpdatesPending: Boolean; override;
    function CancelUpdates: ISQLQuery; override;
    function FindKey(const KeyValues: array of TVarRec): Boolean; override;
    function Params: TSQLParams; override;
    function SQLCommand: string; override;
    function TotalPages: Integer; override;
    function RowsAffected: Integer; override;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload; override;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload; override;
    function SetAutoIncField(const AFieldName: string): ISQLQuery; override;
    function SetAutoIncGeneratorName(const AGeneratorName: string): ISQLQuery; override;
  end;
{$IFEND}

implementation

{$IF DEFINED(INFRA_FIREDAC)}
{ TQueryEngineFireDAC }

function TQueryEngineFireDAC.Add(Str: string): ISQLQuery;
begin
  Result := Self;
  FComandoSQL.Add(Str);
end;

function TQueryEngineFireDAC.ApplyUpdates: Boolean;
begin
  Result := FQuery.ApplyUpdates(0) = 0;
end;

function TQueryEngineFireDAC.CancelUpdates: ISQLQuery;
begin
  Result := Self;
  if FQuery.Active then
    FQuery.CancelUpdates;
end;

function TQueryEngineFireDAC.Clear: ISQLQuery;
begin
  Result := Self;
  FParams.Clear;
  FQuery.SQL.Clear;
  FComandoSQL.Clear;
end;

function TQueryEngineFireDAC.Close: ISQLQuery;
begin
  Result := Self;
  FQuery.Close;
end;

constructor TQueryEngineFireDAC.Create(
  const AConnection: TDbEngineAbstract);
begin
  inherited;
  FDbEngine := AConnection;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := TFDConnection(AConnection.ConnectionComponent);
  FQuery.CachedUpdates := True;
  FQuery.FetchOptions.Mode := fmAll;
  FQuery.FetchOptions.RowsetSize := -1;
  FQuery.ResourceOptions.ParamCreate := False;
  FParams := TSQLParams.Create;
  FComandoSQL := TStringList.Create;
end;

function TQueryEngineFireDAC.DataSet: TDataSet;
begin
  Result := FQuery;
end;

destructor TQueryEngineFireDAC.Destroy;
begin
  FQuery.Close;
  FQuery.Free;
  FParams.Free;
  FComandoSQL.Free;
  inherited;
end;

function TQueryEngineFireDAC.Exec(const AReturn: Boolean = False): ISQLQuery;
begin
  Result := Self;
  try
    FQuery.Close;
    FQuery.IndexFieldNames := EmptyStr;
    FQuery.SQL.Clear;
    FQuery.SQL.Assign(FComandoSQL);
    if FParams.Count > 0 then
      FQuery.Params.Assign(FParams);
    if AReturn then
      FQuery.Open
    else
    begin
      if FParams.ArraySize > 0 then
        FQuery.Execute(FParams.ArraySize)
      else
        FQuery.ExecSQL;
    end;
    FRowsAffected := FQuery.RowsAffected;
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao executar Query: ' + FQuery.SQL.Text + sLineBreak +
        'Excessão: ' + E.message);
    end;
  end;
end;

function TQueryEngineFireDAC.FindKey(
  const KeyValues: array of TVarRec): Boolean;
begin
  Result := FQuery.Active and (FQuery.FindKey(KeyValues));
end;

function TQueryEngineFireDAC.IndexFieldNames(
  const Fields: string): ISQLQuery;
begin
  Result := Self;
  FQuery.IndexFieldNames := Fields;
end;

function TQueryEngineFireDAC.IndexFieldNames: string;
begin
  Result := FQuery.IndexFieldNames;
end;

function TQueryEngineFireDAC.Open: ISQLQuery;
begin
  Result := Self;
  try
    FQuery.Close;
    FQuery.IndexFieldNames := EmptyStr;
    if FPaginate and (FRowsPerPage > 0) and (FPage > 0) then
      FDMLGenerator.GenerateSQLPaginating(FPage, FRowsPerPage, FComandoSQL);
    FQuery.SQL.Assign(FComandoSQL);
    if FParams.Count > 0 then
      FQuery.Params.Assign(FParams);
    FQuery.Open;
    if FPaginate then
      FTotalPages := FQuery.FieldByName(FDMLGenerator.GetColumnNameTotalPages).AsInteger;
  except
    on E: Exception do
    begin
      raise;
    end;
  end;
end;

function TQueryEngineFireDAC.Params: TSQLParams;
var
  LParams: TParams;
  I: Integer;
begin
  if (Pos(':', FComandoSQL.Text) > 0) and (FParams.Count = 0) then
  begin
    FParams.Clear;
    LParams := TParams.Create;
    try
      LParams.ParseSQL(FComandoSQL.Text, True);
      for I := 0 to LParams.Count - 1 do
      begin
        FParams.Add.Name := LParams.Items[I].Name;
      end;
    finally
      LParams.Free;
    end;
  end;
  Result := FParams;
end;

function TQueryEngineFireDAC.ProviderFlags(const FieldName: string;
  ProviderFlags: TProviderFlags): ISQLQuery;
begin
  Result := Self;
  FQuery.FieldByName(FieldName).ProviderFlags := ProviderFlags;
end;

function TQueryEngineFireDAC.Refresh: Boolean;
begin
  FQuery.Refresh;
  Result := True;
end;

function TQueryEngineFireDAC.Reset: ISQLQuery;
begin
  Result := Self;
  Close.Clear;
end;

function TQueryEngineFireDAC.RetornaAutoIncremento(
  const ASequenceName: string): Integer;
begin
  Self.Reset
    .Add('SELECT GEN_ID(' + ASequenceName + ',1) AS CONTROLE FROM RDB$DATABASE');
  Result := Self.Open.DataSet.FieldByName('CONTROLE').AsInteger;
end;

function TQueryEngineFireDAC.RetornaAutoIncremento(const ASequenceName,
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

function TQueryEngineFireDAC.RowsAffected: Integer;
begin
  Result := FRowsAffected;
end;

function TQueryEngineFireDAC.SetAutoIncField(const AFieldName: string): ISQLQuery;
begin
  Result := Self;
  if FQuery.Active then
    raise Exception.Create('SetAutoIncField - Operation not allowed with active dataset.');
  FQuery.UpdateOptions.AutoIncFields := AFieldName;
end;

function TQueryEngineFireDAC.SetAutoIncGeneratorName(const AGeneratorName: string): ISQLQuery;
begin
  Result := Self;
  if FQuery.Active then
    raise Exception.Create('SetAutoIncGeneratorName - Operation not allowed with active dataset.');
  FQuery.UpdateOptions.GeneratorName := AGeneratorName;
end;

function TQueryEngineFireDAC.SQLCommand: string;
begin
  Result := FComandoSQL.Text;
end;

function TQueryEngineFireDAC.TotalPages: Integer;
begin
  Result := FTotalPages;
end;

function TQueryEngineFireDAC.UpdatesPending: Boolean;
begin
  Result := FQuery.Active and (FQuery.UpdatesPending);
end;
{$IFEND}

end.
