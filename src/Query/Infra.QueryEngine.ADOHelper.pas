unit Infra.QueryEngine.ADOHelper;

interface

{$IF DEFINED(INFRA_ADO)}
uses
  ADODB,
  Data.DB;

type
  TSQLParamsHelper = class helper for TParameter
  private

    function GetAsInteger: Integer;
    procedure SetAsInteger(const Value: Integer);
    function GetAsString: string;
    procedure SetAsString(const Value: string);
    function GetAsDateTime: TDateTime;
    procedure SetAsDateTime(const Value: TDateTime);
    function GetAsDate: TDate;
    procedure SetAsDate(const Value: TDate);
    function GetAsLargeInt: Int64;
    procedure SetAsLargeInt(const Value: Int64);
    function GetAsFloat: Double;
    procedure SetAsFloat(const Value: Double);
    function GetAsCurrency: Currency;
    procedure SetAsCurrency(const Value: Currency);
  public
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsString: string read GetAsString write SetAsString;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsDate: TDate read GetAsDate write SetAsDate;
    property AsLargeInt: Int64 read GetAsLargeInt write SetAsLargeInt;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
  end;
{$IFEND}

implementation

{ TSQLParamsHelper }

{$IF DEFINED(INFRA_ADO)}


function TSQLParamsHelper.GetAsCurrency: Currency;
begin
  Result := Self.Value;
end;

function TSQLParamsHelper.GetAsDate: TDate;
begin
  Result := Self.Value;
end;

function TSQLParamsHelper.GetAsDateTime: TDateTime;
begin
  Result := Self.Value;
end;

function TSQLParamsHelper.GetAsFloat: Double;
begin
  Result := Self.Value;
end;

function TSQLParamsHelper.GetAsInteger: Integer;
begin
  Result := Self.Value;
end;

function TSQLParamsHelper.GetAsLargeInt: Int64;
begin
  Result := Self.Value;
end;

function TSQLParamsHelper.GetAsString: string;
begin
  Result := Self.Value;
end;

procedure TSQLParamsHelper.SetAsCurrency(const Value: Currency);
begin
  Self.Value := Value;
end;

procedure TSQLParamsHelper.SetAsDate(const Value: TDate);
begin
  Self.DataType := ftDate;
  Self.Value := Value;
end;

procedure TSQLParamsHelper.SetAsDateTime(const Value: TDateTime);
begin
  Self.DataType := ftDateTime;
  Self.Value := Value;
end;

procedure TSQLParamsHelper.SetAsFloat(const Value: Double);
begin
  Self.Value := Value;
end;

procedure TSQLParamsHelper.SetAsInteger(const Value: Integer);
begin
  Self.Value := Value;
end;

procedure TSQLParamsHelper.SetAsLargeInt(const Value: Int64);
begin
  Self.Value := Value;
end;

procedure TSQLParamsHelper.SetAsString(const Value: string);
begin
  Self.Value := Value;
end;
{$ENDIF}

end.
