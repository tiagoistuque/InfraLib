unit Infra.QueryEngine.ADO;

interface
{$IF DEFINED(INFRA_ADO)}
uses
  DB,
  Classes, SysUtils,
  ADODB,
  Infra.QueryEngine.Abstract,
  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract,
  Infra.QueryEngine.Contract;

type

  TQueryEngineADO = class(TQueryEngineAbstract)
  private
    FQuery: TADOQuery;
    FParams: TSQLParams;
    FRowsAffected: Integer;
    procedure SynchronizeParams;
  public
    constructor Create(const AConnection: TDbEngineAbstract); override;
    destructor Destroy; override;

    function Reset: IQueryEngine; override;
    function Clear: IQueryEngine; override;
    function Add(Str: string): IQueryEngine; override;
    function Open(const ATimeout: Integer = 0): IQueryEngine; override;
    function Exec(const AReturn: Boolean = False; const ATimeout: Integer = 0): IQueryEngine; override;
    function Close: IQueryEngine; override;
    function IndexFieldNames(const Fields: string): IQueryEngine; override;
  	function IndexFieldNames: string; override;
    function DataSet: TDataSet; override;
    function ProviderFlags(const FieldName: string; ProviderFlags: TProviderFlags): IQueryEngine; override;
    function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions): Boolean; override;
    function ApplyUpdates: Boolean; override;
    function Refresh: Boolean; override;
    function UpdatesPending: Boolean; override;
    function CancelUpdates: IQueryEngine; override;
    function Params: TSQLParams; override;
    function FieldDefs: TFieldDefs; override;
    function TotalPages: Integer; override;
    function RowsAffected: Integer; override;
    function RetornaAutoIncremento(const ASequenceName: string): Integer; overload; override;
    function RetornaAutoIncremento(const ASequenceName, ATableDest, AFieldDest: string): Integer; overload; override;
  end;
{$IFEND}
implementation
{$IF DEFINED(INFRA_ADO)}

{ TQueryEngineADO }

function TQueryEngineADO.Add(Str: string): IQueryEngine;
begin
  Result := Self;
  FComandoSQL.Add(Str);
end;

function TQueryEngineADO.ApplyUpdates: Boolean;
begin
  FQuery.UpdateBatch(arAll);
  Result := FQuery.RowsAffected > 0;
end;

function TQueryEngineADO.CancelUpdates: IQueryEngine;
begin
  Result := Self;
  FQuery.CancelBatch(arAll);
end;

function TQueryEngineADO.Clear: IQueryEngine;
begin
  Result := Self;
  FParams.Clear;
  FQuery.SQL.Clear;
  FComandoSQL.Clear;
end;

function TQueryEngineADO.Close: IQueryEngine;
begin
  Result := Self;
  FQuery.Parameters.Clear;
  FQuery.Close;
end;

constructor TQueryEngineADO.Create(
  const AConnection: TDbEngineAbstract);
var
  LADOCommand: TADOCommand;
begin
  inherited;
  FQuery := TADOQuery.Create(nil);
  FQuery.Connection := TADOConnection(AConnection.ConnectionComponent);
  LADOCommand := TADOCommand.Create(FQuery);
  FParams := TSQLParams.Create(LADOCommand, TParameter);
end;

function TQueryEngineADO.DataSet: TDataSet;
begin
  Result := FQuery;
end;

destructor TQueryEngineADO.Destroy;
begin
  FParams.Free;
  FQuery.Close;
  FQuery.Free;
  inherited;
end;

function TQueryEngineADO.Exec(const AReturn: Boolean = False; const ATimeout: Integer = 0): IQueryEngine;
begin
  Result := Self;
  try
    FExecutionStartTime := Now;
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Assign(FComandoSQL);
    if FParams.Count > 0 then
      SynchronizeParams;
    if ATimeout > 0 then
      FQuery.CommandTimeout := ATimeout;
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

function TQueryEngineADO.IndexFieldNames(
  const Fields: string): IQueryEngine;
begin
  Result := Self;
  FQuery.Sort := StringReplace(Fields, ';', ',', [rfReplaceAll]);
end;

function TQueryEngineADO.IndexFieldNames: string;
begin
  Result := FQuery.Sort;
end;

function TQueryEngineADO.Locate(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
begin
  Result := FQuery.Locate(KeyFields, KeyValues, Options);
end;

function TQueryEngineADO.Open(const ATimeout: Integer = 0): IQueryEngine;
begin
  Result := Self;
  try
    FExecutionStartTime := Now;
    FQuery.Close;
    FQuery.SQL.Clear;
    if FPaginate and (FRowsPerPage > 0) and (FPage > 0) then
      FDMLGenerator.GenerateSQLPaginating(FPage, FRowsPerPage, FComandoSQL);
    FQuery.SQL.Assign(FComandoSQL);
    if Assigned(FParams) and (FParams.Count > 0) then
      SynchronizeParams;
    if ATimeout > 0 then
      FQuery.CommandTimeout := ATimeout;
    FQuery.Open;
    FExecutionEndTime := Now;
    if FPaginate then
      FTotalPages := FQuery.FieldByName(FDMLGenerator.GetColumnNameTotalPages).AsInteger;
  except
    on E: Exception do
    begin
      raise;
    end;
  end;
end;

function TQueryEngineADO.Params: TSQLParams;
begin
  if (Pos(':', FComandoSQL.Text) > 0) and (FParams.Count = 0) then
  begin
    FParams.Clear;
    FParams.ParseSQL(FComandoSQL.Text, True);
  end;
  Result := FParams;
end;

function TQueryEngineADO.FieldDefs: TFieldDefs;
begin
  if FQuery.SQL.IsEmpty then
  begin
    FQuery.Close;
    FQuery.SQL.Clear;
    if FPaginate and (FRowsPerPage > 0) and (FPage > 0) then
      FDMLGenerator.GenerateSQLPaginating(FPage, FRowsPerPage, FComandoSQL);
    FQuery.SQL.Assign(FComandoSQL);
    if Assigned(FParams) and (FParams.Count > 0) then
      SynchronizeParams;
  end;
  Result := FQuery.FieldDefs;
end;

function TQueryEngineADO.ProviderFlags(const FieldName: string;
  ProviderFlags: TProviderFlags): IQueryEngine;
begin
  Result := Self;
  FQuery.FieldByName(FieldName).ProviderFlags := ProviderFlags;
end;

function TQueryEngineADO.Refresh: Boolean;
begin
  FQuery.Refresh;
  Result := True;
end;

function TQueryEngineADO.Reset: IQueryEngine;
begin
  Result := Self;
  Close.Clear;
end;

function TQueryEngineADO.RetornaAutoIncremento(
  const ASequenceName: string): Integer;
begin
  Self.Reset
    .Add('SELECT GEN_ID(' + ASequenceName + ',1) AS CONTROLE FROM RDB$DATABASE');
  Result := Self.Open.DataSet.FieldByName('CONTROLE').AsInteger;
end;

function TQueryEngineADO.RetornaAutoIncremento(const ASequenceName,
  ATableDest, AFieldDest: string): Integer;
begin
  Result := Self.RetornaAutoIncremento(ASequenceName);
  Self.Reset
    .Add('SELECT COUNT(*) AS QTDE')
    .Add('FROM ' + ATableDest)
    .Add('WHERE ' + AFieldDest + ' = :FIELDVALUE');
  Self.Params.ParamByName('FIELDVALUE').Value := Result;
  if Self.Open.DataSet.FieldByName('QTDE').AsInteger > 0 then
  begin
    RetornaAutoIncremento(ASequenceName, ATableDest, AFieldDest);
  end;
end;

function TQueryEngineADO.RowsAffected: Integer;
begin
  Result := FRowsAffected;
end;

function TQueryEngineADO.TotalPages: Integer;
begin
  Result := FTotalPages;
end;

function TQueryEngineADO.UpdatesPending: Boolean;
begin
  Result := FQuery.Active and ( rsPendingChanges in FQuery.RecordStatus );
end;

procedure TQueryEngineADO.SynchronizeParams;
var
  I: Integer;
  SrcParam: TParameter;
  DestParam: TParameter;
begin
  for I := 0 to FParams.Count - 1 do
  begin
    SrcParam := FParams[I];
    if FQuery.Parameters.FindParam(SrcParam.Name) <> nil then
    begin
      DestParam := FQuery.Parameters.ParamByName(SrcParam.Name);
      DestParam.DataType := SrcParam.DataType;
      DestParam.Value := SrcParam.Value;
    end;
  end;
end;

{$IFEND}
end.
