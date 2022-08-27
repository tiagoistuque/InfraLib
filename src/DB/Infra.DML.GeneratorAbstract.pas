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
  if ASQL.Text.IsEmpty then
    raise Exception.Create('SQL command must be provided before applying pagination.');
end;

function TDMLGeneratorAbstract.GetOrderByFields(const ASQL: string): string;
var
  LInitialPos: Integer;
  LOrderByFields: string;
begin
  LInitialPos := System.Pos('ORDER BY', ASQL);
  Assert(LInitialPos > 0, 'An ORDER BY clause must be specified to use paging. Tip: Use a single space between ORDER BY words.');
  LOrderByFields := Trim(Copy(ASQL, LInitialPos + 9, Length(ASQL)));
  Result := LOrderByFields;
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
