unit Infra.DBEngine.Trace.Types;

interface

uses
  {$IF CompilerVersion >= 22.0}System.JSON,{$ELSE}DBXJSON,{$IFEND}
  Generics.Collections;

type
  TDbEngineTraceCache = TObjectList<TJSONObject>;
  TDbEngineTraceLog = TJSONObject;
  TDbEngineTraceLogItemNumber = {$IFDEF FPC}TJSONFloatNumber{$ELSE}TJSONNumber{$ENDIF};
  TDbEngineTraceLogItemString = TJSONString;

implementation

end.
