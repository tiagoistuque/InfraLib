unit Infra.DBEngine.Trace.Manager;

{$IFDEF FPC }
  {$MODE DELPHI}
{$ENDIF}

interface

uses
{$IFDEF FPC }
  SysUtils, Classes, SyncObjs, Generics.Collections, fpjson,
{$ELSE}
  SysUtils,
  {$IF CompilerVersion >= 22.0}System.JSON,{$ELSE}DBXJSON,{$IFEND}
  SyncObjs, Classes, Generics.Collections,
{$ENDIF}
  Infra.DbEngine.Trace.Types, Infra.DbEngine.Trace.Provider, Infra.DbEngine.Trace.Thread,
  Infra.DBEngine.Context;

type
  TDbEngineTraceManager = class;
  TDbEngineTraceManagerClass = class of TDbEngineTraceManager;

  TDbEngineTraceManager = class(TDbEngineTraceThread)
  private
    class var FProviderList: TList<IDbEngineTraceProvider>;
    class var FDefaultManager: TDbEngineTraceManager;
  protected
    procedure DispatchLogCache; override;
    class function GetProviderList: TList<IDbEngineTraceProvider>;
    class function ByteArrayToHexString(const AValue: TBytes; const ASeparator: string = ''): string;
    class function ValidateValue(const AValue: Integer): TDbEngineTraceLogItemNumber; overload;
    class function ValidateValue(const AValue: string): TDbEngineTraceLogItemString; overload;
    class function ValidateValue(const AValue: TBytes; const ASeparator: string = ''): TDbEngineTraceLogItemString; overload;
  	class function ValidateValue(const AValue: TDateTime; const AShort: Boolean): TDbEngineTraceLogItemString; overload;
    class function GetDefaultManager: TDbEngineTraceManager; static;
  public
    class function DbEngineContextRequest: TDbEngineContextRequest; overload;
    class function RegisterProvider(const AProvider: IDbEngineTraceProvider): TDbEngineTraceManagerClass;
    class property DefaultManager: TDbEngineTraceManager read GetDefaultManager;
    class destructor UnInitialize;
  end;

implementation

uses
  DateUtils;

{ TDbEngineTraceManager }

procedure DefaultDbEngineContextRequest(AReq: TDbEngineTrace);
var
  LLog: TDbEngineTraceLog;
begin
  LLog := TDbEngineTraceLog.Create;
  try
    LLog.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('time', TDbEngineTraceManager.ValidateValue(AReq.TimeStamp, False));
    LLog.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('time_short', TDbEngineTraceManager.ValidateValue(AReq.TimeStamp, True));
    LLog.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('request_tracelog', TDbEngineTraceManager.ValidateValue(AReq.TraceLog));
  finally
    TDbEngineTraceManager.GetDefaultManager.NewLog(LLog);
  end;
end;

class function TDbEngineTraceManager.ByteArrayToHexString(const AValue: TBytes; const ASeparator: string): string;
var
  LIndex: integer;
begin
  Result := '';
  for LIndex := Low(AValue) to High(AValue) do
    Result := Result + ASeparator + IntToHex(AValue[LIndex], 2);
end;

procedure TDbEngineTraceManager.DispatchLogCache;
var
  LLogCache: TDbEngineTraceCache;
  LDbEngineTraceProvider: IDbEngineTraceProvider;
  I: Integer;
begin
  LLogCache := ExtractLogCache;
  try
    for I := 0 to Pred(GetProviderList.Count) do
    begin
      if Supports(GetProviderList.Items[I], IDbEngineTraceProvider, LDbEngineTraceProvider)  then
        LDbEngineTraceProvider.ReceiveLogCache(LLogCache);
    end;
  finally
    LLogCache.Free;
  end;
end;

class function TDbEngineTraceManager.GetDefaultManager: TDbEngineTraceManager;
begin
  if not Assigned(FDefaultManager) then
  begin
    FDefaultManager := TDbEngineTraceManager.Create(True);
    FDefaultManager.FreeOnTerminate := False;
    FDefaultManager.Start;
  end;
  Result := FDefaultManager;
end;

class function TDbEngineTraceManager.GetProviderList: TList<IDbEngineTraceProvider>;
begin
  if FProviderList = nil then
    FProviderList := TList<IDbEngineTraceProvider>.Create;
  Result := FProviderList;
end;

class function TDbEngineTraceManager.DbEngineContextRequest: TDbEngineContextRequest;
begin
  Result := DefaultDbEngineContextRequest;
end;

class function TDbEngineTraceManager.RegisterProvider(const AProvider: IDbEngineTraceProvider): TDbEngineTraceManagerClass;
begin
  Result := TDbEngineTraceManager;
  GetProviderList.Add(AProvider);
end;

class destructor TDbEngineTraceManager.UnInitialize;
begin
  if FProviderList <> nil then
  begin
    FProviderList.Free;
  end;
  if FDefaultManager <> nil then
  begin
    FDefaultManager.Terminate;
    FDefaultManager.GetEvent.SetEvent;
    FDefaultManager.WaitFor;
    FDefaultManager.Free;
  end;
end;

class function TDbEngineTraceManager.ValidateValue(const AValue: TBytes; const ASeparator: string = ''): TDbEngineTraceLogItemString;
begin
  Result := TDbEngineTraceLogItemString.Create(ByteArrayToHexString(AValue, ASeparator));
end;

class function TDbEngineTraceManager.ValidateValue(const AValue: Integer): TDbEngineTraceLogItemNumber;
begin
  Result := TDbEngineTraceLogItemNumber.Create(AValue);
end;

class function TDbEngineTraceManager.ValidateValue(const AValue: string): TDbEngineTraceLogItemString;
begin
  Result := TDbEngineTraceLogItemString.Create(AValue);
end;

class function TDbEngineTraceManager.ValidateValue(const AValue: TDateTime; const AShort: Boolean): TDbEngineTraceLogItemString;
begin
  if AShort then
  	Result := TDbEngineTraceLogItemString.Create(FormatDateTime('dd/mm/yyyy hh:mm:ss.zzz', AValue))
  else
    Result := TDbEngineTraceLogItemString.Create(FormatDateTime('dd/MMMM/yyyy hh:mm:ss.zzz', AValue));
end;

end.
