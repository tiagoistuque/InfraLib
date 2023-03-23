unit Infra.DBEngine.Trace;

interface

uses
  Infra.DbEngine.Trace.Manager,
  Infra.DbEngine.Trace.Provider,
  Infra.DbEngine.Trace.Thread,
  Infra.DbEngine.Trace.Types,
  Infra.DbEngine.Trace.Utils;

type

  TDbEngineTraceManager = Infra.DbEngine.Trace.Manager.TDbEngineTraceManager;
  TDbEngineTraceManagerClass = Infra.DbEngine.Trace.Manager.TDbEngineTraceManagerClass;
  IDbEngineTraceProvider = Infra.DbEngine.Trace.Provider.IDbEngineTraceProvider;
  TDbEngineTraceCache = Infra.DbEngine.Trace.Types.TDbEngineTraceCache;
  TDbEngineTraceLog = Infra.DbEngine.Trace.Types.TDbEngineTraceLog;
  TDbEngineTraceThread = Infra.DbEngine.Trace.Thread.TDbEngineTraceThread;
  TDbEngineTraceLogItemNumber = Infra.DbEngine.Trace.Types.TDbEngineTraceLogItemNumber;
  TDbEngineTraceLogItemString = Infra.DbEngine.Trace.Types.TDbEngineTraceLogItemString;
  TDbEngineTraceUtils = Infra.DbEngine.Trace.Utils.TDbEngineTraceUtils;

implementation

end.
