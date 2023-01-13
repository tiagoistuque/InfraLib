unit Infra.DML.Generator.MSAccess;

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
  TDMLGeneratorMSAcc = class(TDMLGeneratorAbstract)
  public
    procedure GenerateSQLPaginating(const APage, ARowsPerPage: Integer; const ASQL: TStrings); override;
    function GetColumnNameTotalPages: string; override;
  end;

implementation

uses
  Infra.DBDriver.Register, Infra.DBEngine.Contract;

{ TDMLGeneratorMSAcc }

procedure TDMLGeneratorMSAcc.GenerateSQLPaginating(const APage, ARowsPerPage: Integer; const ASQL: TStrings);
begin
  inherited;
  raise Exception.Create('GenerateSQLPaginating not implemented: '+Self.UnitName);
end;

function TDMLGeneratorMSAcc.GetColumnNameTotalPages: string;
begin
  raise Exception.Create('GenerateSQLPaginating not implemented: '+Self.UnitName);
end;

initialization

TDBDriverRegister.RegisterDriver(TDBDriver.MSAcc, {$IF DEFINED(INFRA_ORMBR)}TDriverName.dnMSSQL, {$IFEND}TDMLGeneratorMSAcc.Create);

end.
