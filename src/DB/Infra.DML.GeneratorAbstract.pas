unit Infra.DML.GeneratorAbstract;

interface

uses
  Classes, SysUtils,
  Infra.DML.Contracts;

type
  TDMLGeneratorAbstract = class abstract(TInterfacedObject, IDMLGeneratorCommand)
  protected
    function GetOrderByFields(const ASQL: string): string; virtual;
    procedure ValidateOrderByFields(const AOrderByFields: string); virtual;
    function RemoveOrderBy(const ASQL: string): string; virtual;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GenerateSQLPaginating(const APage, ARowsPerPage: Integer; const ASQL: TStrings); virtual;
    function GetColumnNameTotalPages: string; virtual; abstract;
  end;

implementation

{ TDMLGeneratorAbstract }

constructor TDMLGeneratorAbstract.Create;
begin

end;

destructor TDMLGeneratorAbstract.Destroy;
begin

  inherited;
end;

procedure TDMLGeneratorAbstract.GenerateSQLPaginating(const APage, ARowsPerPage: Integer; const ASQL: TStrings);
begin
  if Trim(ASQL.Text) = EmptyStr then
    raise Exception.Create('SQL command must be provided before applying pagination.');
end;

function TDMLGeneratorAbstract.GetOrderByFields(const ASQL: string): string;
var
  LInitialPos: Integer;
  LOrderByFields: string;
begin
  LInitialPos := System.Pos('ORDER BY', AnsiUpperCase(ASQL));
  Assert(LInitialPos > 0, 'An ORDER BY clause must be specified to use pagination. Tip: Use a single space between ORDER BY words.');
  LOrderByFields := Trim(Copy(ASQL, LInitialPos + 9, Length(ASQL)));
  if Copy(LOrderByFields, Length(LOrderByFields) - 1, 1) = ';' then
    LOrderByFields := Copy(LOrderByFields, 1, Length(LOrderByFields) - 1);
  Result := LOrderByFields;
end;

function TDMLGeneratorAbstract.RemoveOrderBy(const ASQL: string): string;
var
  LInitialPos: Integer;
  LSQL: string;
begin
  Result := ASQL;
  LInitialPos := System.Pos('ORDER BY', AnsiUpperCase(ASQL));
  if LInitialPos > 0 then
  begin
    LSQL := ASQL;
    Result := Trim(Copy(ASQL, 1, LInitialPos-1));
  end;
end;

procedure TDMLGeneratorAbstract.ValidateOrderByFields(const AOrderByFields: string);
var
  LStrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    LStrings.Delimiter := '.';
    LStrings.StrictDelimiter := True;
    LStrings.QuoteChar := #0;
    LStrings.DelimitedText := AOrderByFields;
    if LStrings.Count > 1 then
      raise Exception.Create('In order to use the pagination feature, it is not allowed to use table '
        + 'references in the column names of the ORDER BY clause. For example, '
        + 'instead of using ORDER BY mytable.mycolumn use only mycolumn. '
        + 'Tip: if necessary use aliases for column names, for example: '
        + 'SELECT mytable.mycolumns AS mytable_mycolumn from mytable ORDER BY mytable_mycolumn.');
  finally
    LStrings.Free;
  end;
end;

end.
