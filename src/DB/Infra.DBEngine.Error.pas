unit Infra.DBEngine.Error;

interface

uses
  SysUtils,
  Classes,
  Types,
  DB;

type

  ETransactionException = class(Exception);
  EStartTransactionException = class(ETransactionException);
  ECommitTransactionException = class(ETransactionException);
  ERollbackTransactionException = class(ETransactionException);
  TDBEngineError = class;
  TDBEngineErrorClass = class of TDBEngineError;

  {$SCOPEDENUMS ON}
  TDBEngineCommandExceptionKind = (Other, NoDataFound, TooManyRows,
    RecordLocked, UKViolated, FKViolated, ObjNotExists,
    UserPwdInvalid, UserPwdExpired, UserPwdWillExpire, CmdAborted,
    ServerGone, ServerOutput, ArrExecMalfunc, InvalidParams);
  {$SCOPEDENUMS OFF}

  TDBEngineError = class(TObject)
  private
    FMessage: string;
    FErrorCode: Integer;
    FLevel: Integer;
    FObjName: String;
    FKind: TDBEngineCommandExceptionKind;
    FCommandTextOffset: Integer;
    FRowIndex: Integer;
  protected
    procedure Assign(ASrc: TDBEngineError); virtual;
  public
    constructor Create; overload; virtual;
    constructor Create(ALevel, AErrorCode: Integer; const AMessage,
      AObjName: String; AKind: TDBEngineCommandExceptionKind; ACmdOffset, ARowIndex: Integer); overload; virtual;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property Kind: TDBEngineCommandExceptionKind read FKind write FKind;
    property Level: Integer read FLevel write FLevel;
    property Message: String read FMessage write FMessage;
    property ObjName: String read FObjName write FObjName;
    property CommandTextOffset: Integer read FCommandTextOffset write FCommandTextOffset;
    property RowIndex: Integer read FRowIndex write FRowIndex;
  end;

  EDBEngineException = class(EDatabaseError)
  private
    FCode: Integer;
    FObjName: string;
    FItems: TList;
    FParams: TStrings;
    FSQL: String;
    function GetErrors(AIndex: Integer): TDBEngineError;
    function GetErrorCount: Integer;
    function GetKind: TDBEngineCommandExceptionKind;
    function GetErrorCode: Integer;
    procedure SetParams(const AValue: TStrings);

  protected
    function GetErrorClass: TDBEngineErrorClass; virtual;
    function AppendError: TDBEngineError; overload;

  public
    constructor Create; overload; virtual;
    constructor Create(ACode: Integer; const AMessage: String); overload;
    destructor Destroy; override;
    function AppendError(ALevel, AErrorCode: Integer;
      const AMessage, AObjName: String; AKind: TDBEngineCommandExceptionKind;
      ACmdOffset, ARowIndex: Integer): TDBEngineError; overload;
    procedure Duplicate(var AValue: EDBEngineException); virtual;
    procedure Append(AItem: TDBEngineError);
    procedure Remove(AItem: TDBEngineError);
    procedure Clear;
    procedure Merge(AValue: EDBEngineException; AIndex: Integer);
    property Code: Integer read FCode write FCode;
    property ObjName: String read FObjName write FObjName;
    property ErrorCount: Integer read GetErrorCount;
    property Errors[Index: Integer]: TDBEngineError read GetErrors; default;
    property ErrorCode: Integer read GetErrorCode;
    property Kind: TDBEngineCommandExceptionKind read GetKind;
    property Params: TStrings read FParams write SetParams;
    property SQL: String read FSQL write FSQL;

  end;

implementation

{ EInfraDBEngineError }

constructor EDBEngineException.Create;
begin
  inherited Create('');
  FItems := TList.Create;
  FParams := TStringList.Create;
end;

procedure EDBEngineException.Append(AItem: TDBEngineError);
begin
  FItems.Add(AItem);
end;

function EDBEngineException.AppendError(ALevel, AErrorCode: Integer;
  const AMessage, AObjName: String; AKind: TDBEngineCommandExceptionKind;
  ACmdOffset, ARowIndex: Integer): TDBEngineError;
begin
  Result := GetErrorClass.Create(ALevel, AErrorCode, AMessage, AObjName,
    AKind, ACmdOffset, ARowIndex);
  Append(Result);
end;

function EDBEngineException.AppendError: TDBEngineError;
begin
  Result := GetErrorClass.Create;
  Append(Result);
end;

procedure EDBEngineException.Clear;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    TDBEngineError(FItems[i]).Destroy;
  FItems.Clear;
end;

constructor EDBEngineException.Create(ACode: Integer;
  const AMessage: String);
begin
  inherited Create(AMessage);
  FCode := ACode;
  FItems := TList.Create;
  FParams := TStringList.Create;
end;

destructor EDBEngineException.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  FreeAndNil(FParams);
  inherited Destroy;
end;

procedure EDBEngineException.Duplicate(var AValue: EDBEngineException);
var
  oItem: TDBEngineError;
  i: Integer;
begin
  if AValue = nil then
    AValue := EDBEngineException(ClassType).Create;
  AValue.Message := Message;
  AValue.Code := FCode;
  AValue.ObjName := FObjName;
  EDBEngineException(AValue).FParams.SetStrings(FParams);
  EDBEngineException(AValue).FSQL := FSQL;
  for i := 0 to FItems.Count - 1 do
  begin
    oItem := EDBEngineException(AValue).AppendError;
    oItem.Assign(TDBEngineError(FItems[i]));
  end;
end;

function EDBEngineException.GetErrorClass: TDBEngineErrorClass;
begin
  Result := TDBEngineError;
end;

function EDBEngineException.GetErrorCode: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FItems.Count - 1 do
    if Errors[i].ErrorCode <> 0 then
    begin
      Result := Errors[i].ErrorCode;
      Break;
    end;
end;

function EDBEngineException.GetErrorCount: Integer;
begin
  Result := FItems.Count;
end;

function EDBEngineException.GetErrors(AIndex: Integer): TDBEngineError;
begin
  Result := TDBEngineError(FItems[AIndex]);
end;

function EDBEngineException.GetKind: TDBEngineCommandExceptionKind;
var
  i: Integer;
begin
  Result := TDBEngineCommandExceptionKind.Other;
  for i := 0 to FItems.Count - 1 do
    if Errors[i].Kind <> TDBEngineCommandExceptionKind.Other then
    begin
      Result := Errors[i].Kind;
      Break;
    end;
end;

procedure EDBEngineException.Merge(AValue: EDBEngineException;
  AIndex: Integer);
var
  i: Integer;
begin
  for i := AValue.ErrorCount - 1 downto 0 do
  begin
    FItems.Insert(AIndex, AValue[i]);
    AValue.FItems.Delete(i);
  end;
end;

procedure EDBEngineException.Remove(AItem: TDBEngineError);
begin
  FItems.Remove(AItem);
end;

procedure EDBEngineException.SetParams(const AValue: TStrings);
begin
  FParams.SetStrings(AValue);
end;

{ TDBEngineError }

procedure TDBEngineError.Assign(ASrc: TDBEngineError);
begin
  FLevel := ASrc.Level;
  FErrorCode := ASrc.ErrorCode;
  FMessage := ASrc.Message;
  FObjName := ASrc.ObjName;
  FKind := ASrc.Kind;
  FCommandTextOffset := ASrc.CommandTextOffset;
  FRowIndex := ASrc.RowIndex;
end;

constructor TDBEngineError.Create;
begin
  inherited Create;
  FCommandTextOffset := -1;
  FRowIndex := -1;
end;

constructor TDBEngineError.Create(ALevel, AErrorCode: Integer;
  const AMessage, AObjName: String; AKind: TDBEngineCommandExceptionKind;
  ACmdOffset, ARowIndex: Integer);
begin
  Create;
  FLevel := ALevel;
  FErrorCode := AErrorCode;
  FMessage := AMessage;
  FObjName := AObjName;
  FKind := AKind;
  FCommandTextOffset := ACmdOffset;
  FRowIndex := ARowIndex;
end;

end.
