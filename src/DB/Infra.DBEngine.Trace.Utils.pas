unit Infra.DBEngine.Trace.Utils;

interface

type
  StringArray = TArray<string>;

  TDbEngineTraceUtils = class
  public
    class function GetFormatParams(AFormat: string): StringArray;
  end;

implementation

uses
  SysUtils, PerlRegEx, Infra.System.RegularExpressions;

{ TDbEngineTraceUtils }
const
  REGEXP_PARAM = '\$\{\w+\}';

class function TDbEngineTraceUtils.GetFormatParams(AFormat: string): StringArray;
var
  LRegex: TRegEx;
  LMatches: TMatchCollection;
  LIndex: Integer;
begin
  LRegex := TRegEx.Create(REGEXP_PARAM);
  LMatches := LRegex.Matches(AFormat);

  SetLength(Result, LMatches.Count);

  for LIndex := 0 to LMatches.Count - 1 do
  begin
//    Result[LIndex] := LMatches.Item[LIndex].Value.Substring(2, LMatches.Item[LIndex].Value.Length - 3)
    Result[LIndex] := Copy(LMatches.Item[LIndex].Value, 3, Length(LMatches.Item[LIndex].Value) - 3);
  end;
end;

end.
