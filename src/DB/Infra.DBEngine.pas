unit Infra.DBEngine;

interface

uses
  Infra.DBEngine.Contract,
  Infra.DBEngine.Abstract,
  Infra.DBConfig;

type
  IDBEngine = Infra.DBEngine.Contract.IDbEngineFactory;

  TDBEngine = class
  public
    class function New(const ADbConfig: IDbEngineConfig): IDBEngine;
    class function Create(const ADbConfig: IDbEngineConfig): TDbEngineAbstract;
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
  {$ENDIF}
{$ENDIF}

class function TDBEngine.New(const ADbConfig: IDbEngineConfig): IDBEngine;
begin
{$IF DEFINED(FPC)}
  {$IF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig);
  {$ELSE}
  Result := TDbEngineSQLConnector.Create(ADbConfig);
  {$ENDIF}
{$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TDbEngineDBExpress.Create(ADbConfig);
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig);
  {$ELSE}
  Result := TDbEngineFireDAC.Create(ADbConfig);
  {$ENDIF}
{$ENDIF}
end;

class function TDBEngine.Create(const ADbConfig: IDbEngineConfig): TDbEngineAbstract;
begin
{$IF DEFINED(FPC)}
  {$IF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig);
  {$ELSE}
  Result := TDbEngineSQLConnector.Create(ADbConfig);
  {$ENDIF}
{$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TDbEngineDBExpress.Create(ADbConfig);
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TDbEngineZeos.Create(ADbConfig);
  {$ELSE}
  Result := TDbEngineFireDAC.Create(ADbConfig);
  {$ENDIF}
{$ENDIF}
end;

end.
