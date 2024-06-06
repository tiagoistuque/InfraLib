unit Infra.QueryEngine.FireDAC;

interface

{$IF DEFINED(INFRA_FIREDAC)}


uses
  DB,
  Classes, SysUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.Util,
  Infra.DBEngine.Error,
  Infra.QueryEngine.Abstract,
  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract,
  Infra.QueryEngine.Contract;

type

  TQueryEngineFireDAC = class(TQueryEngineAbstract)
  private
    FQuery: TFDQuery;
    FParams: TSQLParams;
    FRowsAffected: Integer;
    procedure _ParseException(const aExceptionFD: EFDDBEngineException; var aExceptionDBEngine: EDBEngineException);
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
    procedure FindNearest(const AKeyValues: array of const); override;
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

{$IF DEFINED(INFRA_FIREDAC)}


function TQueryEngineFireDAC.Add(Str: string): IQueryEngine;
begin
  Result := Self;
  FComandoSQL.Add(Str);
end;

function TQueryEngineFireDAC.ApplyUpdates: Boolean;
begin
  Result := FQuery.ApplyUpdates(0) = 0;
end;

function TQueryEngineFireDAC.CancelUpdates: IQueryEngine;
begin
  Result := Self;
  if FQuery.Active then
    FQuery.CancelUpdates;
end;

function TQueryEngineFireDAC.Clear: IQueryEngine;
begin
  Result := Self;
  FParams.Clear;
  FQuery.SQL.Clear;
  FComandoSQL.Clear;
end;

function TQueryEngineFireDAC.Close: IQueryEngine;
begin
  Result := Self;
  FQuery.Close;
end;

constructor TQueryEngineFireDAC.Create(
  const AConnection: TDbEngineAbstract);
begin
  inherited;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := TFDConnection(AConnection.ConnectionComponent);
  FQuery.CachedUpdates := True;
  FQuery.FetchOptions.Mode := fmAll;
  FQuery.FetchOptions.RowsetSize := -1;
  FQuery.ResourceOptions.ParamCreate := False;
  FParams := TSQLParams.Create;
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
  inherited;
end;

procedure TQueryEngineFireDAC._ParseException(const aExceptionFD: EFDDBEngineException; var aExceptionDBEngine: EDBEngineException);
var
  I: Integer;
  LKind: TDBEngineCommandExceptionKind;
begin
  aExceptionDBEngine.ObjName := aExceptionFD.FDObjName;
  aExceptionDBEngine.SQL := aExceptionFD.SQL;
  aExceptionDBEngine.Code := aExceptionFD.FDCode;

  case aExceptionFD.Kind of
    ekOther:
      LKind := TDBEngineCommandExceptionKind.Other;
    ekNoDataFound:
      LKind := TDBEngineCommandExceptionKind.NoDataFound;
    ekTooManyRows:
      LKind := TDBEngineCommandExceptionKind.TooManyRows;
    ekRecordLocked:
      LKind := TDBEngineCommandExceptionKind.RecordLocked;
    ekUKViolated:
      LKind := TDBEngineCommandExceptionKind.UKViolated;
    ekFKViolated:
      LKind := TDBEngineCommandExceptionKind.FKViolated;
    ekObjNotExists:
      LKind := TDBEngineCommandExceptionKind.ObjNotExists;
    ekUserPwdInvalid:
      LKind := TDBEngineCommandExceptionKind.UserPwdInvalid;
    ekUserPwdExpired:
      LKind := TDBEngineCommandExceptionKind.UserPwdExpired;
    ekUserPwdWillExpire:
      LKind := TDBEngineCommandExceptionKind.UserPwdWillExpire;
    ekCmdAborted:
      LKind := TDBEngineCommandExceptionKind.CmdAborted;
    ekServerGone:
      LKind := TDBEngineCommandExceptionKind.ServerGone;
    ekServerOutput:
      LKind := TDBEngineCommandExceptionKind.ServerOutput;
    ekArrExecMalfunc:
      LKind := TDBEngineCommandExceptionKind.ArrExecMalfunc;
    ekInvalidParams:
      LKind := TDBEngineCommandExceptionKind.InvalidParams;
    else
      LKind := TDBEngineCommandExceptionKind.Other;
  end;

  for I := 0 to aExceptionFD.ErrorCount - 1 do
  begin
    aExceptionDBEngine.AppendError(
      aExceptionFD.Errors[I].Level,
      aExceptionFD.Errors[I].ErrorCode,
      aExceptionFD.Errors[I].Message,
      aExceptionFD.Errors[I].ObjName,
      LKind,
      aExceptionFD.Errors[I].CommandTextOffset,
      aExceptionFD.Errors[I].RowIndex);
  end;

end;

function TQueryEngineFireDAC.Exec(const AReturn: Boolean = False): IQueryEngine;
var
  LEx: EDBEngineException;
begin
  Result := Self;
  try
    FExecutionStartTime := Now;
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
    FExecutionEndTime := Now;
    FRowsAffected := FQuery.RowsAffected;
  except
    on E: EFDDBEngineException do
    begin
      LEx := EDBEngineException.Create(E.FDCode, E.Message);
      _ParseException(E, LEx);
      raise LEx;
    end;
    on E: Exception do
    begin
      raise Exception.Create('Erro ao executar Query: ' + FQuery.SQL.Text + sLineBreak +
        'Excessão: ' + E.Message);
    end;
  end;
end;

function TQueryEngineFireDAC.FindKey(
  const KeyValues: array of TVarRec): Boolean;
begin
  Result := FQuery.Active and (FQuery.FindKey(KeyValues));
end;

procedure TQueryEngineFireDAC.FindNearest(const AKeyValues: array of const);
begin
  FQuery.FindNearest(AKeyValues);
end;

function TQueryEngineFireDAC.IndexFieldNames(
  const Fields: string): IQueryEngine;
begin
  Result := Self;
  FQuery.IndexFieldNames := Fields;
end;

function TQueryEngineFireDAC.IndexFieldNames: string;
begin
  Result := FQuery.IndexFieldNames;
end;

function TQueryEngineFireDAC.Open: IQueryEngine;
begin
  Result := Self;
  try
    FExecutionStartTime := Now;
    FQuery.Close;
    FQuery.IndexFieldNames := EmptyStr;
    if FPaginate and (FRowsPerPage > 0) and (FPage > 0) then
      FDMLGenerator.GenerateSQLPaginating(FPage, FRowsPerPage, FComandoSQL);
    FQuery.SQL.Assign(FComandoSQL);
    if FParams.Count > 0 then
      FQuery.Params.Assign(FParams);
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
  ProviderFlags: TProviderFlags): IQueryEngine;
begin
  Result := Self;
  FQuery.FieldByName(FieldName).ProviderFlags := ProviderFlags;
end;

function TQueryEngineFireDAC.Refresh: Boolean;
begin
  FQuery.Refresh;
  Result := True;
end;

function TQueryEngineFireDAC.Reset: IQueryEngine;
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

function TQueryEngineFireDAC.SetAutoIncField(const AFieldName: string): IQueryEngine;
begin
  Result := Self;
  if FQuery.Active then
    raise Exception.Create('SetAutoIncField - Operation not allowed with active dataset.');
  FQuery.UpdateOptions.AutoIncFields := AFieldName;
end;

function TQueryEngineFireDAC.SetAutoIncGeneratorName(const AGeneratorName: string): IQueryEngine;
begin
  Result := Self;
  if FQuery.Active then
    raise Exception.Create('SetAutoIncGeneratorName - Operation not allowed with active dataset.');
  FQuery.UpdateOptions.GeneratorName := AGeneratorName;
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
