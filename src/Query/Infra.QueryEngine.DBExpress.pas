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

function TQueryEngineDBExpress.Add(Str: string): ISQLQuery;
begin
  Result := Self;
  FComandoSQL.Add(Str);
end;

function TQueryEngineDBExpress.ApplyUpdates: Boolean;
begin
  Result := FClientDataSet.ApplyUpdates(0) = 0;
end;

function TQueryEngineDBExpress.CancelUpdates: ISQLQuery;
begin
  Result := Self;
  if FClientDataSet.Active then
    FClientDataSet.CancelUpdates;
end;

function TQueryEngineDBExpress.Clear: ISQLQuery;
begin
  Result := Self;
  FParams.Clear;
  FQuery.SQL.Clear;
  FComandoSQL.Clear;
end;

function TQueryEngineDBExpress.Close: ISQLQuery;
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
  FDbEngine := AConnection;
  FQuery := TSQLQuery.Create(DM);
  FQuery.SQLConnection := TSQLConnection(AConnection.ConnectionComponent);

  FProvider := TDataSetProvider.Create(DM);
  FProvider.Options := [poUseQuoteChar];
  FProvider.UpdateMode := upWhereKeyOnly;

  FClientDataSet := TClientDataSet.Create(DM);
  FProvider.DataSet := FQuery;
  FProvider.Name := 'DSP' + Format('%s%d',[FormatDateTime('YYYYMMDDHHNNSSZZZ', Now), Random(32768)]);
  FClientDataSet.ProviderName := FProvider.Name;

  FParams := TSQLParams.Create;
  FComandoSQL := TStringList.Create;
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
  FComandoSQL.Free;
  inherited;
end;

function TQueryEngineDBExpress.Exec(const AReturn: Boolean = False): ISQLQuery;
begin
  Result := Self;
  try
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Assign(FComandoSQL);
    if FParams.Count > 0 then
      FQuery.Params.Assign(FParams);
    if AReturn then
      FQuery.Open
    else
      FQuery.ExecSQL;
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
  const Fields: string): ISQLQuery;
begin
  Result := Self;
  FClientDataSet.IndexFieldNames := Fields;
end;

function TQueryEngineDBExpress.IndexFieldNames: string;
begin
  Result := FClientDataSet.IndexFieldNames;	
end;

function TQueryEngineDBExpress.Open: ISQLQuery;
begin
  Result := Self;
  try
    FQuery.Close;
    FClientDataSet.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Assign(FComandoSQL);
    if Assigned(FParams) and (FParams.Count > 0) then
      FQuery.Params.Assign(FParams);
    FQuery.Open;
    FClientDataSet.Open;
  except
    on E: Exception do
    begin
      raise;
    end;
  end;
end;

function TQueryEngineDBExpress.Params: TSQLParams;
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
        FParams.AddParameter.Name := LParams.Items[I].Name;
      end;
    finally
      LParams.Free;
    end;
  end;
  Result := FParams;
end;

function TQueryEngineDBExpress.ProviderFlags(const FieldName: string;
  ProviderFlags: TProviderFlags): ISQLQuery;
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

function TQueryEngineDBExpress.Reset: ISQLQuery;
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

function TQueryEngineDBExpress.SQLCommand: string;
begin
  Result := FComandoSQL.Text;
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
