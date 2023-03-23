unit Infra.DBEngine.Context;

interface

uses
  SysUtils;

type
  TDbEngineTrace = class
  private
    FTraceLog: string;
    FTimeStamp: TDateTime;

  public
    constructor Create(const ATraceLog: string);
    property TimeStamp: TDateTime read FTimeStamp;
    property TraceLog: string read FTraceLog;
  end;


  TDbEngineContextRequest = reference to procedure(AReq: TDbEngineTrace);

implementation

{ TDbEngineContext }

constructor TDbEngineTrace.Create(const ATraceLog: string);
begin
  FTraceLog := ATraceLog;
  FTimeStamp := Now();
end;

end.
