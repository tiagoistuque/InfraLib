unit Infra.DML.Generator.MSSQL;

interface

uses
  Classes, SysUtils,
  {$IF DEFINED(INFRA_ORMBR)}
  dbebr.factory.interfaces,
  dbcbr.ddl.Generator.MSSQL,
  dbcbr.metadata.MSSQL,
  ormbr.DML.Generator.MSSQL,
  {$IFEND}
  Infra.DML.GeneratorAbstract;

type
  TDMLGeneratorMLSQL = class(TDMLGeneratorAbstract)
  public
    procedure GenerateSQLPaginating(const APage, ARowsPerPage: Integer; const ASQL: TStrings); override;
    function GetColumnNameTotalPages: string; override;
  end;

implementation

uses
  Infra.DBDriver.Register, Infra.DBEngine.Contract;

{ TDMLGeneratorMLSQL }

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
    'SELECT *' + sLineBreak +
    'FROM Data_CTE' + sLineBreak +
    'CROSS JOIN TotalPages' + sLineBreak +
    'ORDER BY ' + MacroOrderByFields + sLineBreak +
    'OFFSET (' + MacroPageNum + ' - 1) * ' + MacroRowsPerPage + ' ROWS' + sLineBreak +
    'FETCH NEXT ' + MacroRowsPerPage + ' ROWS ONLY;';

procedure TDMLGeneratorMLSQL.GenerateSQLPaginating(const APage, ARowsPerPage: Integer; const ASQL: TStrings);
var
  LSQLCommand: string;
  LSQLPaginating: string;
  LOrderByFields: string;
begin
  inherited;
  LSQLCommand := ASQL.Text;
  LOrderByFields := GetOrderByFields(LSQLCommand);
  ValidateOrderByFields(LOrderByFields);
  LSQLCommand := RemoveOrderBy(LSQLCommand);
  LSQLPaginating := TemplatePaginating;
  LSQLPaginating := StringReplace(LSQLPaginating, MacroSQLCommand, LSQLCommand, [rfReplaceAll]);
  LSQLPaginating := StringReplace(LSQLPaginating, MacroOrderByFields, LOrderByFields, [rfReplaceAll]);
  LSQLPaginating := StringReplace(LSQLPaginating, MacroPageNum, APage.ToString, [rfReplaceAll]);
  LSQLPaginating := StringReplace(LSQLPaginating, MacroRowsPerPage, ARowsPerPage.ToString, [rfReplaceAll]);

  ASQL.Clear;
  ASQL.Text := LSQLPaginating;
end;

function TDMLGeneratorMLSQL.GetColumnNameTotalPages: string;
begin
  Result := ColumnNameTotalPages;
end;

initialization

TDBDriverRegister.RegisterDriver(TDBDriver.MSSQL, {$IF DEFINED(INFRA_ORMBR)}TDriverName.dnMSSQL, {$IFEND}TDMLGeneratorMLSQL.Create);

end.
