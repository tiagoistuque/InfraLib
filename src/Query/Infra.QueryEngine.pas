unit Infra.QueryEngine;

interface

uses
  Infra.DBEngine.Contract,
  Infra.QueryEngine.Contract,
  Infra.QueryEngine.Abstract;

type
  IQueryEngine = Infra.QueryEngine.Contract.ISQLQuery;

  TQueryEngine = class
  public
    class function New(const AConnection: IDbEngineFactory): IQueryEngine;
    class function Create(const AConnection: IDbEngineFactory): TQueryEngineFactory;
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
{$ENDIF}
{$ENDIF}


class function TQueryEngine.New(const AConnection: IDbEngineFactory): IQueryEngine;
begin
  {$IF DEFINED(FPC)}
  {$IF DEFINED(INFRA_ZEOS)}
  Result := TQueryEngineZeos.Create(AConnection);
  {$ELSE}
  Result := TQueryEngineSQLConnector.Create(AConnection);
  {$ENDIF}
  {$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TQueryEngineDBExpress.Create(AConnection);
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TQueryEngineZeos.Create(AConnection);
  {$ELSE}
  Result := TQueryEngineFireDAC.Create(AConnection);
  {$ENDIF}
  {$ENDIF}
end;

class function TQueryEngine.Create(const AConnection: IDbEngineFactory): TQueryEngineFactory;
begin
  {$IF DEFINED(FPC)}
  {$IF DEFINED(INFRA_ZEOS)}
  Result := TQueryEngineZeos.Create(AConnection);
  {$ELSE}
  Result := TQueryEngineSQLConnector.Create(AConnection);
  {$ENDIF}
  {$ELSE}
  {$IF DEFINED(INFRA_DBEXPRESS)}
  Result := TQueryEngineDBExpress.Create(AConnection);
  {$ELSEIF DEFINED(INFRA_ZEOS)}
  Result := TQueryEngineZeos.Create(AConnection);
  {$ELSE}
  Result := TQueryEngineFireDAC.Create(AConnection);
  {$ENDIF}
  {$ENDIF}
end;

end.
