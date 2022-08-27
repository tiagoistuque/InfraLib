unit Infra.QueryEngine;

interface

uses
  Infra.DBEngine.Contract,
  Infra.DBEngine.Abstract,
  Infra.QueryEngine.Contract,
  Infra.QueryEngine.Abstract;

type
  IQueryEngine = Infra.QueryEngine.Contract.ISQLQuery;

  TQueryEngine = class
  public
    class function New(const AConnection: TDbEngineAbstract): IQueryEngine;
    class function Create(const AConnection: TDbEngineAbstract): TQueryEngineAbstract;
  end;

implementation

uses
  {$IF DEFINED(FPC)}
  Infra.QueryEngine.LazDB;
  {$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Infra.QueryEngine.DBExpress;
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Infra.QueryEngine.Zeos;
{$ELSE}
  Infra.QueryEngine.FireDAC;
{$IFEND}
{$IFEND}


class function TQueryEngine.New(const AConnection: TDbEngineAbstract): IQueryEngine;
begin
  {$IF DEFINED(FPC)}
  {$IF DEFINED(INFRA_ZEOS)}
  Result := TQueryEngineZeos.Create(AConnection);
  {$ELSE}
  Result := TQueryEngineSQLConnector.Create(AConnection);
  {$IFEND}
  {$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TQueryEngineDBExpress.Create(AConnection);
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TQueryEngineZeos.Create(AConnection);
  {$ELSE}
  Result := TQueryEngineFireDAC.Create(AConnection);
  {$IFEND}
  {$IFEND}
end;

class function TQueryEngine.Create(const AConnection: TDbEngineAbstract): TQueryEngineAbstract;
begin
  {$IF DEFINED(FPC)}
  {$IF DEFINED(INFRA_ZEOS)}
  Result := TQueryEngineZeos.Create(AConnection);
  {$ELSE}
  Result := TQueryEngineSQLConnector.Create(AConnection);
  {$IFEND}
  {$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TQueryEngineDBExpress.Create(AConnection);
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TQueryEngineZeos.Create(AConnection);
  {$ELSE}
  Result := TQueryEngineFireDAC.Create(AConnection);
  {$IFEND}
  {$IFEND}
end;

end.
