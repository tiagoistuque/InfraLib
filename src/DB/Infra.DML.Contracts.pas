unit Infra.DML.Contracts;

interface

uses
  Classes;

type
  IDMLGeneratorCommand = interface
    ['{32E747AC-2894-4296-A615-B2F1F9F7E6A3}']
    procedure GenerateSQLPaginating(const APage, ARowsPerPage: Integer; const ASQL: TStrings);
    function GetColumnNameTotalPages: string;
  end;

implementation

end.
