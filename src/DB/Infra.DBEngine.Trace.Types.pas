unit Infra.DBEngine.Trace.Types;

interface

uses
  JSON, Generics.Collections;

type
  TDbEngineTraceCache = TObjectList<TJSONObject>;
  TDbEngineTraceLog = TJSONObject;
  TDbEngineTraceLogItemNumber = {$IFDEF FPC}TJSONFloatNumber{$ELSE}TJSONNumber{$ENDIF};
  TDbEngineTraceLogItemString = TJSONString;

implementation

end.
