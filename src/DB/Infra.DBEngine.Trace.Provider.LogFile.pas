unit Infra.DBEngine.Trace.Provider.LogFile;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  Classes,
{$ELSE}
  System.Classes,
  Winapi.Windows,
{$ENDIF}
  Infra.DbEngine.Trace;

type
  TDbEngineTraceLogFileConfig = class
  private
    FLogFormat: string;
    FDir: string;
    FLogName: string;
  public
    constructor Create;
    function SetLogFormat(const ALogFormat: string): TDbEngineTraceLogFileConfig;
    function SetDir(const ADir: string): TDbEngineTraceLogFileConfig;
    function SetLogName(const ALogName: string): TDbEngineTraceLogFileConfig;
    function GetLogFormat(out ALogFormat: string): TDbEngineTraceLogFileConfig;
    function GetDir(out ADir: string): TDbEngineTraceLogFileConfig;
    function GetLogName(out ALogName: string): TDbEngineTraceLogFileConfig;
    class function New: TDbEngineTraceLogFileConfig;
  end;

  TDbEngineTraceProviderLogFileManager = class(TDbEngineTraceThread)
  private
    FConfig: TDbEngineTraceLogFileConfig;
  protected
    procedure DispatchLogCache; override;
  public
    destructor Destroy; override;
    function SetConfig(AConfig: TDbEngineTraceLogFileConfig): TDbEngineTraceProviderLogFileManager;
  end;

  TDbEngineTraceProviderLogFile = class(TInterfacedObject, IDbEngineTraceProvider)
  private
    FDbEngineTraceProviderLogFileManager: TDbEngineTraceProviderLogFileManager;
  public
    constructor Create(const AConfig: TDbEngineTraceLogFileConfig = nil);
    destructor Destroy; override;
    procedure ReceiveLogCache(const aLogCache: TDbEngineTraceCache);
    class function New(const AConfig: TDbEngineTraceLogFileConfig = nil): IDbEngineTraceProvider;
  end;

implementation

uses
{$IFDEF FPC}
  SysUtils, fpJSON, SyncObjs;
{$ELSE}
  System.SysUtils, System.IOUtils, System.JSON, System.SyncObjs;
{$ENDIF}

{ TDbEngineTraceProviderLogFile }

const
  DEFAULT_DBENGINE_LOG_FORMAT =
    '[${time}] "${database}" "${request_tracelog}"';

constructor TDbEngineTraceProviderLogFile.Create(const AConfig: TDbEngineTraceLogFileConfig = nil);
begin
  FDbEngineTraceProviderLogFileManager := TDbEngineTraceProviderLogFileManager.Create(True);
  FDbEngineTraceProviderLogFileManager.SetConfig(AConfig);
  FDbEngineTraceProviderLogFileManager.FreeOnTerminate := False;
  FDbEngineTraceProviderLogFileManager.Start;
end;

destructor TDbEngineTraceProviderLogFile.Destroy;
begin
  FDbEngineTraceProviderLogFileManager.Terminate;
  FDbEngineTraceProviderLogFileManager.GetEvent.SetEvent;
  FDbEngineTraceProviderLogFileManager.WaitFor;
  FDbEngineTraceProviderLogFileManager.Free;
  inherited;
end;

procedure TDbEngineTraceProviderLogFile.ReceiveLogCache(const aLogCache: TDbEngineTraceCache);
var
  I: Integer;
begin
  for I := 0 to Pred(ALogCache.Count) do
    FDbEngineTraceProviderLogFileManager.NewLog(TDbEngineTraceLog(ALogCache.Items[0].Clone));
end;

class function TDbEngineTraceProviderLogFile.New(const AConfig: TDbEngineTraceLogFileConfig = nil): IDbEngineTraceProvider;
begin
  Result := TDbEngineTraceProviderLogFile.Create(AConfig);
end;

destructor TDbEngineTraceProviderLogFileManager.Destroy;
begin
  FreeAndNil(FConfig);
  inherited;
end;

procedure TDbEngineTraceProviderLogFileManager.DispatchLogCache;
var
  I, Z: Integer;
  LLogCache: TDbEngineTraceCache;
  LLog: TDbEngineTraceLog;
  LParams: TArray<string>;
  LValue: {$IFDEF FPC}TDbEngineTraceLogItemString{$ELSE}string{$ENDIF};
  LLogStr, LFilename, LLogName: string;
  LTextFile: TextFile;
begin
  if FConfig = nil then
    FConfig := TDbEngineTraceLogFileConfig.New;
  FConfig.GetLogFormat(LLogStr).GetDir(LFilename);
  FConfig.GetLogFormat(LLogStr).GetLogName(LLogName);

  if (LFilename <> EmptyStr) and (not DirectoryExists(LFilename)) then
    ForceDirectories(LFilename);
  {$IFDEF FPC}
  LFilename := ConcatPaths([LFilename, LLogName + '_' + FormatDateTime('yyyy-mm-dd', Now()) + '.log']);
  {$ELSE}
  LFilename := TPath.Combine(LFilename, LLogName + '_' + FormatDateTime('yyyy-mm-dd', Now()) + '.log');
  {$ENDIF}
  LLogCache := ExtractLogCache;
  try
    if LLogCache.Count = 0 then
      Exit;
    AssignFile(LTextFile, LFilename);
    if (FileExists(LFilename)) then
      Append(LTextFile)
    else
      Rewrite(LTextFile);
    try
      for I := 0 to Pred(LLogCache.Count) do
      begin
        LLog := LLogCache.Items[I] as TDbEngineTraceLog;
        LParams := TDbEngineTraceUtils.GetFormatParams(FConfig.FLogFormat);
        for Z := Low(LParams) to High(LParams) do
        begin
          {$IFDEF FPC}
          if LLog.Find(LParams[Z], LValue) then
            LLogStr := LLogStr.Replace('${' + LParams[Z] + '}', LValue.AsString);
          {$ELSE}
          if LLog.TryGetValue<string>(LParams[Z], LValue) then
            LLogStr := LLogStr.Replace('${' + LParams[Z] + '}', LValue);
          {$ENDIF}
        end;
      end;
      WriteLn(LTextFile, LLogStr);
    finally
      CloseFile(LTextFile);
    end;
  finally
    LLogCache.Free;
  end;
end;

function TDbEngineTraceProviderLogFileManager.SetConfig(AConfig: TDbEngineTraceLogFileConfig): TDbEngineTraceProviderLogFileManager;
begin
  FConfig := AConfig;
  Result := Self;
end;

{ TDbEngineTraceConfig }

constructor TDbEngineTraceLogFileConfig.Create;
{$IFNDEF FPC}
const
  INVALID_PATH = '\\?\';
var
  LPath: array[0..MAX_PATH - 1] of Char;
{$ENDIF}
begin
  FLogFormat := DEFAULT_DBENGINE_LOG_FORMAT;
  {$IFDEF FPC}
  FDir := ExtractFileDir(ParamStr(0));
  FLogName := 'TraceSQL_';
  {$ELSE}
  SetString(FDir, LPath, GetModuleFileName(HInstance, LPath, SizeOf(LPath)));
  FDir := FDir.Replace(INVALID_PATH, EmptyStr);
  FLogName := 'TraceSQL_' + ExtractFileName(FDir).Replace(ExtractFileExt(FDir), EmptyStr);
  FDir := ExtractFilePath(FDir) ;
  {$ENDIF}
  FDir := FDir + '\logs';
end;

function TDbEngineTraceLogFileConfig.GetDir(out ADir: string): TDbEngineTraceLogFileConfig;
begin
  ADir := FDir;
  Result := Self;
end;

function TDbEngineTraceLogFileConfig.GetLogFormat(out ALogFormat: string): TDbEngineTraceLogFileConfig;
begin
  ALogFormat := FLogFormat;
  Result := Self;
end;

function TDbEngineTraceLogFileConfig.GetLogName(out ALogName: string): TDbEngineTraceLogFileConfig;
begin
  ALogName := FLogName;
  Result := Self;
end;

class function TDbEngineTraceLogFileConfig.New: TDbEngineTraceLogFileConfig;
begin
  Result := TDbEngineTraceLogFileConfig.Create;
end;

function TDbEngineTraceLogFileConfig.SetDir(const ADir: string): TDbEngineTraceLogFileConfig;
begin
  FDir := ADir;
  Result := Self;
end;

function TDbEngineTraceLogFileConfig.SetLogFormat(const ALogFormat: string): TDbEngineTraceLogFileConfig;
begin
  FLogFormat := ALogFormat;
  Result := Self;
end;

function TDbEngineTraceLogFileConfig.SetLogName(const ALogName: string): TDbEngineTraceLogFileConfig;
begin
  FLogName := ALogName;
  Result := Self;
end;

end.
