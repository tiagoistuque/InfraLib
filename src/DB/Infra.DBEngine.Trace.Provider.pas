unit Infra.DBEngine.Trace.Provider;

interface

uses
  Infra.DBEngine.Trace.Types;

type
  IDbEngineTraceProvider = interface
    ['{A07EBEF4-EAFF-441F-A835-3907D634F2C0}']
    procedure ReceiveLogCache(const aLogCache: TDbEngineTraceCache);
  end;

implementation

end.
