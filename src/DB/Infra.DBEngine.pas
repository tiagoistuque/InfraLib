unit Infra.DBEngine;

interface

uses
  Infra.DBEngine.Contract,
  Infra.DBEngine.Abstract,
  Infra.DBConfig,
  Infra.DBConfig.IniFile,
  Infra.DBConfig.EnvironmentVar;

type
  IDBEngine = Infra.DBEngine.Contract.IDbEngineFactory;
  IDbEngineConfig = Infra.DBEngine.Contract.IDbEngineConfig;

  TDbDriver = Infra.DBEngine.Contract.TDBDriver;

  {$SCOPEDENUMS ON}
  TTypeConfig = (EnvironmentVariable, IniFile, Memory);
  {$SCOPEDENUMS OFF}

  TDBConfigFactory = class
  public
    class function CreateConfig(const AType: TTypeConfig; const APrefixVariable: string = ''): IDbEngineConfig;
  end;

  TDBEngine = class
  public
    class function New(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''): IDBEngine;
    class function Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''): TDbEngineFactory;
  end;

implementation

uses
  {$IF DEFINED(FPC)}
  //
  {$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Infra.DBEngine.DBExpress;
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Infra.DBEngine.Zeos;
{$ELSE}
  Infra.DBEngine.FireDAC;
{$IFEND}
{$IFEND}


class function TDBEngine.New(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''): IDBEngine;
begin
  {$IF DEFINED(FPC)}
  {$IF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig, ASuffixDBname);
  {$ELSE}
  Result := TDbEngineSQLConnector.Create(ADbConfig, ASuffixDBname);
  {$IFEND}
  {$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TDbEngineDBExpress.Create(ADbConfig, ASuffixDBname);
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig, ASuffixDBname);
  {$ELSE}
  Result := TDbEngineFireDAC.Create(ADbConfig, ASuffixDBname);
  {$IFEND}
  {$IFEND}
end;

class function TDBEngine.Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''): TDbEngineFactory;
begin
  {$IF DEFINED(FPC)}
  {$IF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig, ASuffixDBname);
  {$ELSE}
  Result := TDbEngineSQLConnector.Create(ADbConfig, ASuffixDBname);
  {$IFEND}
  {$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TDbEngineDBExpress.Create(ADbConfig, ASuffixDBname);
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig, ASuffixDBname);
  {$ELSE}
  Result := TDbEngineFireDAC.Create(ADbConfig, ASuffixDBname);
  {$IFEND}
  {$IFEND}
end;

{ TDBConfigFactory }

class function TDBConfigFactory.CreateConfig(
  const AType: TTypeConfig; const APrefixVariable: string): IDbEngineConfig;
begin
  case AType of
    TTypeConfig.EnvironmentVariable:
      Result := TDBConfigEnvironmentVar.New(APrefixVariable);
    TTypeConfig.IniFile:
      Result := TDBConfigIniFile.New(APrefixVariable);
  end;
end;

end.
