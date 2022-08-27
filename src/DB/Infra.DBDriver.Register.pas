unit Infra.DBDriver.Register;

interface

uses
  SysUtils,
  Generics.Collections,
  Infra.DbEngine.Contract,
  Infra.DML.Contracts;

type
  TDBDriverRegister = class
  strict private
    class var FDBDrivers: TDictionary<TDBDriver, IDMLGeneratorCommand>;
  private
    class constructor Create;
    class destructor Destroy;
  public
    class procedure RegisterDriver(const ADriver: TDBDriver; const ADriverSQL: IDMLGeneratorCommand);
    class function GetDriver(const ADriver: TDBDriver): IDMLGeneratorCommand;
  end;

implementation

class constructor TDBDriverRegister.Create;
begin
  FDBDrivers := TDictionary<TDBDriver, IDMLGeneratorCommand>.Create;
end;

class destructor TDBDriverRegister.Destroy;
begin
  FDBDrivers.Clear;
  FDBDrivers.Free;
  inherited;
end;

class function TDBDriverRegister.GetDriver(const ADriver: TDBDriver): IDMLGeneratorCommand;
var
  LDriverName: string;
begin
  if not FDBDrivers.ContainsKey(ADriver) then
  begin
    LDriverName := ADriver.ToString;
    raise Exception.CreateFmt('O driver %s não está registrado. Adicione a unit "Infra.DML.Generator.%s.pas" na cláusula Uses do seu projeto!', [LDriverName, LDriverName]);
  end;
  Result := FDBDrivers[ADriver];
end;

class procedure TDBDriverRegister.RegisterDriver(const ADriver: TDBDriver; const ADriverSQL: IDMLGeneratorCommand);
begin
  FDBDrivers.AddOrSetValue(ADriver, ADriverSQL);
end;

end.
