unit Infra.DBEngine;


interface

uses
  Infra.DBEngine.Contract,
  Infra.DBEngine.Abstract,
  Infra.DBConfig,
  Infra.DBConfig.IniFile,
  Infra.DBConfig.Memory,
  Infra.DBConfig.EnvironmentVar,
  Infra.DBEngine.Error;

type
  IDBEngine = Infra.DBEngine.Contract.IDBEngine;
  IDbEngineConfig = Infra.DBEngine.Contract.IDbEngineConfig;
  TDbEngine = Infra.DBEngine.Abstract.TDbEngineAbstract;
  EDbEngineError = Infra.DBEngine.Error.EDBEngineException;

  TDbDriver = Infra.DBEngine.Contract.TDbDriver;

{$SCOPEDENUMS ON}
  TTypeConfig = (EnvironmentVariable, IniFile, Memory);
{$SCOPEDENUMS OFF}

  TDBConfigFactory = class
  public
    class function CreateConfig(const AType: TTypeConfig; const APrefixVariable: string = ''): IDbEngineConfig;
  end;

  TDBEngineFactory = class
  public
    class function New(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''): IDBEngine;
    class function Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''): TDbEngine;
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
{$ELSEIF DEFINED(INFRA_ADO)}
  Infra.DBEngine.ADODB;
{$ELSE}
  Infra.DBEngine.FireDAC;
{$IFEND}
{$IFEND}
class function TDBEngineFactory.New(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''): IDBEngine;
begin
{$IF DEFINED(FPC)}
{$IF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig, ASuffixDBName);
{$ELSE}
  Result := TDbEngineSQLConnector.Create(ADbConfig, ASuffixDBName);
{$IFEND}
{$ELSE}
{$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TDbEngineDBExpress.Create(ADbConfig, ASuffixDBName);
{$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig, ASuffixDBName);
{$ELSEIF DEFINED(INFRA_ADO)}
  Result := TDbEngineado.Create(ADbConfig, ASuffixDBName);
{$ELSE}
  Result := TDbEngineFireDAC.Create(ADbConfig, ASuffixDBName);
{$IFEND}
{$IFEND}
end;

class function TDBEngineFactory.Create(const ADbConfig: IDbEngineConfig; const ASuffixDBName: string = ''): TDbEngine;
begin
{$IF DEFINED(FPC)}
{$IF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig, ASuffixDBName);
{$ELSE}
  Result := TDbEngineSQLConnector.Create(ADbConfig, ASuffixDBName);
{$IFEND}
{$ELSE}
{$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TDbEngineDBExpress.Create(ADbConfig, ASuffixDBName);
{$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig, ASuffixDBName);
{$ELSEIF DEFINED(INFRA_ADO)}
  Result := TDbEngineado.Create(ADbConfig, ASuffixDBName);
{$ELSE}
  Result := TDbEngineFireDAC.Create(ADbConfig, ASuffixDBName);
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
    TTypeConfig.Memory:
      Result := TDBConfigMemory.New(APrefixVariable);
  end;
end;

end.

