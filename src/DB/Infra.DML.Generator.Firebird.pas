unit Infra.DML.Generator.Firebird;

interface

uses
  Classes, SysUtils,
  {$IF DEFINED(INFRA_ORMBR)}
  dbebr.factory.interfaces,
  dbcbr.ddl.Generator.Firebird,
  dbcbr.metadata.Firebird,
  ormbr.DML.Generator.Firebird,
  {$IFEND}
  Infra.DML.GeneratorAbstract;

type
  TDMLGeneratorFirebid = class(TDMLGeneratorAbstract)
  public
    procedure GenerateSQLPaginating(const APage, ARowsPerPage: Integer; const ASQL: TStrings); override;
    function GetColumnNameTotalPages: string; override;
  end;

implementation

uses
  Infra.DBDriver.Register, Infra.DBEngine.Contract;

{ TDMLGeneratorFirebid }

const
  ColumnNameTotalPages = 'TotalPages';
  MacroSQLCommand = '#SQLCOMMAND#';
  MacroOrderByFields = '#ORDERBYFIELDS#';
  MacroPageNum = '#PAGENUM#';
  MacroRowsPerPage = '#ROWSPERPAGE#';

  TemplatePaginating =
    'WITH Data_CTE ' + sLineBreak +
    'AS' + sLineBreak +
    '(' + sLineBreak +
    '    ' + MacroSQLCommand + sLineBreak +
    '), ' + sLineBreak +
    'Count_CTE ' + sLineBreak +
    'AS ' + sLineBreak +
    '(' + sLineBreak +
    '    SELECT COUNT(*) * 1.0 AS TotalRows FROM Data_CTE' + sLineBreak +
    '),' + sLineBreak +
    'TotalPages' + sLineBreak +
    'AS' + sLineBreak +
    '(' + sLineBreak +
    '	SELECT IIF(TotalRows < ' + MacroRowsPerPage + ', 1, CEILING(TotalRows / ' + MacroRowsPerPage + ')) as TotalPages FROM  Count_CTE' + sLineBreak +
    ')' + sLineBreak +
    'SELECT First ' + MacroRowsPerPage + ' Skip ((' + MacroPageNum + ' - 1) * ' + MacroRowsPerPage + ') *' + sLineBreak +
    'FROM Data_CTE' + sLineBreak +
    'CROSS JOIN TotalPages' + sLineBreak +
    'ORDER BY ' + MacroOrderByFields + ';';

procedure TDMLGeneratorFirebid.GenerateSQLPaginating(const APage, ARowsPerPage: Integer; const ASQL: TStrings);
var
  LSQLCommand: string;
  LSQLPaginating: string;
begin
  inherited;
  LSQLCommand := ASQL.Text;
  LSQLPaginating := TemplatePaginating;
  LSQLPaginating := StringReplace(LSQLPaginating, MacroSQLCommand, LSQLCommand, [rfReplaceAll]);
  LSQLPaginating := StringReplace(LSQLPaginating, MacroOrderByFields, GetOrderByFields(LSQLCommand), [rfReplaceAll]);
  LSQLPaginating := StringReplace(LSQLPaginating, MacroPageNum, IntToStr(APage), [rfReplaceAll]);
  LSQLPaginating := StringReplace(LSQLPaginating, MacroRowsPerPage, IntToStr(ARowsPerPage), [rfReplaceAll]);

  ASQL.Clear;
  ASQL.Text := LSQLPaginating;
end;

function TDMLGeneratorFirebid.GetColumnNameTotalPages: string;
begin
  Result := ColumnNameTotalPages;
end;

initialization

TDBDriverRegister.RegisterDriver(TDBDriver.Firebird, {$IF DEFINED(INFRA_ORMBR)}TDriverName.dnFirebird, {$IFEND}TDMLGeneratorFirebid.Create);
TDBDriverRegister.RegisterDriver(TDBDriver.FirebirdEmbedded, {$IF DEFINED(INFRA_ORMBR)}TDriverName.dnFirebird, {$IFEND}TDMLGeneratorFirebid.Create);

end.
