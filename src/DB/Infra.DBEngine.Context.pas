unit Infra.DBEngine.Context;

interface

uses
  SysUtils;

type
  TDbEngineTrace = class
  private
    FTraceLog: string;
    FTimeStamp: TDateTime;
    FDatabase: String;

  public
    constructor Create(const ATraceLog: string; const aDatabase: string);
    property TimeStamp: TDateTime read FTimeStamp;
    property TraceLog: string read FTraceLog;
    property Database: String read FDatabase;
  end;


  TDbEngineContextRequest = reference to procedure(AReq: TDbEngineTrace);

implementation

{ TDbEngineContext }

constructor TDbEngineTrace.Create(const ATraceLog: string; const aDatabase: string);
begin
  FTraceLog := ATraceLog;
  FDatabase := aDatabase;
  FTimeStamp := Now();
end;

end.
