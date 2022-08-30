unit Infra.DBDriver.Register;

interface

uses
  SysUtils,
  Generics.Collections,
  {$IF DEFINED(INFRA_ORMBR)}
  dbebr.factory.interfaces,
  {$IFEND}
  Infra.DbEngine.Contract,
  Infra.DML.Contracts;

type
  TDBDriverRegister = class
  strict private
    {$IF DEFINED(INFRA_ORMBR)}
    class var FDBDrivers: TDictionary<TDBDriver, TPair<TDriverName, IDMLGeneratorCommand>>;
    {$ELSE}
    class var FDBDrivers: TDictionary<TDBDriver, IDMLGeneratorCommand>;
    {$IFEND}
  private
    class constructor Create;
    class destructor Destroy;
    class procedure _CheckDriverIsRegistered(const ADriver: TDBDriver);
  public
    {$IF DEFINED(INFRA_ORMBR)}
    class function GetDriverName(const ADriver: TDBDriver): TDriverName;
    {$IFEND}
    class procedure RegisterDriver(const ADriver: TDBDriver; {$IF DEFINED(INFRA_ORMBR)}const ADriverName: TDriverName; {$IFEND}const ADML: IDMLGeneratorCommand);
    class function GetDMLGeneratorCommand(const ADriver: TDBDriver): IDMLGeneratorCommand;
  end;

implementation

class constructor TDBDriverRegister.Create;
begin
  {$IF DEFINED(INFRA_ORMBR)}
  FDBDrivers := TDictionary<TDBDriver, TPair<TDriverName, IDMLGeneratorCommand>>.Create;
  {$ELSE}
  FDBDrivers := TDictionary<TDBDriver, IDMLGeneratorCommand>.Create;
  {$IFEND}
end;

class destructor TDBDriverRegister.Destroy;
begin
  FDBDrivers.Clear;
  FDBDrivers.Free;
  inherited;
end;

class function TDBDriverRegister.GetDMLGeneratorCommand(const ADriver: TDBDriver): IDMLGeneratorCommand;
begin
  _CheckDriverIsRegistered(ADriver);
  Result := {$IF DEFINED(INFRA_ORMBR)}FDBDrivers[ADriver].Value{$ELSE}FDBDrivers[ADriver]{$IFEND};
end;

{$IF DEFINED(INFRA_ORMBR)}
class function TDBDriverRegister.GetDriverName(const ADriver: TDBDriver): TDriverName;
begin
  _CheckDriverIsRegistered(ADriver);
  Result := FDBDrivers[ADriver].Key;
end;
{$IFEND}

class procedure TDBDriverRegister.RegisterDriver(const ADriver: TDBDriver; {$IF DEFINED(INFRA_ORMBR)}const ADriverName: TDriverName; {$IFEND}const ADML: IDMLGeneratorCommand);
begin
  {$IF DEFINED(INFRA_ORMBR)}
  FDBDrivers.AddOrSetValue(ADriver, TPair<TDriverName, IDMLGeneratorCommand>.Create(ADriverName, ADML));
  {$ELSE}
  FDBDrivers.AddOrSetValue(ADriver, ADML);
  {$IFEND}
end;

class procedure TDBDriverRegister._CheckDriverIsRegistered(const ADriver: TDBDriver);
var
  LDriverName: string;
begin
  if not FDBDrivers.ContainsKey(ADriver) then
  begin
    LDriverName := ADriver.ToString;
    raise Exception.CreateFmt('O driver %s não está registrado. Adicione a unit "Infra.DML.Generator.%s.pas" na cláusula Uses do seu projeto!', [LDriverName, LDriverName]);
  end;
end;

end.
