unit Infra.DBEngine.Trace.Thread;

{$IFDEF FPC }
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  SysUtils, Classes, SyncObjs, Generics.Collections,
  Infra.DBEngine.Trace.Types;

type

  TDbEngineTraceThread = class;
  TDbEngineTraceThreadClass = class of TDbEngineTraceThread;

  TDbEngineTraceThread = class(TThread)
  private
    { private declarations }
    FCriticalSection: TCriticalSection;
    FEvent: TEvent;
    FLogCache: TDbEngineTraceCache;

  protected
    { protected declarations }
    function GetLogCache: TDbEngineTraceCache;

    function GetCriticalSection: TCriticalSection;
    function ExtractLogCache: TDbEngineTraceCache;
    function ResetLogCache: TDbEngineTraceThread;
    procedure DispatchLogCache; virtual;

  public
    { public declarations }
    function GetEvent: TEvent;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Execute; override;
    function NewLog(ALog: TDbEngineTraceLog): TDbEngineTraceThread;
  end;

implementation

{ TDbEngineTraceThread }

procedure TDbEngineTraceThread.AfterConstruction;
begin
  inherited;
  FEvent := TEvent.Create{$IFDEF FPC}(nil, False, True, TGuid.NewGuid.ToString(True)){$ENDIF};
  FCriticalSection := TCriticalSection.Create;
  FLogCache := TDbEngineTraceCache.Create;
end;

procedure TDbEngineTraceThread.BeforeDestruction;
begin
  FLogCache.Free;
  FEvent.Free;
  FCriticalSection.Free;
  inherited;
end;

procedure TDbEngineTraceThread.DispatchLogCache;
begin

end;

procedure TDbEngineTraceThread.Execute;
var
  LWait: TWaitResult;
begin
{$IFNDEF FPC }
  inherited;
{$ENDIF}
  while not(Self.Terminated) do
  begin
    LWait := GetEvent.WaitFor(INFINITE);
    GetEvent.ResetEvent;
    case LWait of
      wrSignaled:
        begin
          DispatchLogCache;
        end
    else
      Continue;
    end;
  end;
end;

function TDbEngineTraceThread.ExtractLogCache: TDbEngineTraceCache;
var
  LLogCache: TDbEngineTraceCache;
begin
  GetCriticalSection.Enter;
  try
    LLogCache := TDbEngineTraceCache.Create;
    while GetLogCache.Count > 0 do
      LLogCache.Add(
      {$IFDEF FPC }
        GetLogCache.ExtractIndex(0)
      {$ELSE}
        {$IFDEF CompilerVersion >= 33.0}
        GetLogCache.ExtractAt(0)
        {$ELSE}
        GetLogCache.Extract(GetLogCache.Items[0])
        {$ENDIF}
      {$ENDIF}
      );
    Result := LLogCache;
    ResetLogCache;
  finally
    GetCriticalSection.Leave;
  end;
end;

function TDbEngineTraceThread.GetCriticalSection: TCriticalSection;
begin
  Result := FCriticalSection;
end;

function TDbEngineTraceThread.GetEvent: TEvent;
begin
  Result := FEvent;
end;

function TDbEngineTraceThread.GetLogCache: TDbEngineTraceCache;
begin
  Result := FLogCache;
end;

function TDbEngineTraceThread.NewLog(ALog: TDbEngineTraceLog): TDbEngineTraceThread;
begin
  Result := Self;
  GetCriticalSection.Enter;
  try
    GetLogCache.Add(ALog);
  finally
    GetCriticalSection.Leave;
    GetEvent.SetEvent;
  end;
end;

function TDbEngineTraceThread.ResetLogCache: TDbEngineTraceThread;
begin
  Result := Self;
  GetCriticalSection.Enter;
  try
    if GetLogCache <> nil then
      GetLogCache.Clear;
  finally
    GetCriticalSection.Leave;
  end;
end;

end.
