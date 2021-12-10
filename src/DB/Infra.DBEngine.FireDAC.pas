unit Infra.DBEngine.FireDAC;

interface

uses
  SysUtils,
  Classes,
  DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,

  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,

  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.DApt.Intf,
  FireDAC.DApt,

  Infra.DBEngine.Abstract,
  Infra.DBEngine.Contract;

type
  TDbEngineFireDAC = class(TDbEngineAbstract)
  private
    FConnectionComponent: TFDConnection;
  public
    function StartTx: IDbEngineFactory; override;
    function CommitTX: IDbEngineFactory; override;
    function RollbackTx: IDbEngineFactory; override;
    function InTransaction: Boolean; override;
    function InjectConnection(AConn: TComponent; ATransactionObject: TObject): IDbEngineFactory; override;
    function ConnectionComponent: TComponent; override;

  public
    constructor Create(const ADbConfig: IDbEngineConfig); override;
    destructor Destroy; override;

  end;

implementation

{$IF DEFINED(INFRA_ORMBR)} uses dbebr.factory.FireDAC; {$ENDIF}


function TDbEngineFireDAC.CommitTX: IDbEngineFactory;
begin
  Result := Self;
  TFDConnection(FConnectionComponent).Commit;
end;

function TDbEngineFireDAC.ConnectionComponent: TComponent;
begin
  Result := FConnectionComponent;
end;

constructor TDbEngineFireDAC.Create(const ADbConfig: IDbEngineConfig);
begin
  inherited;
  FConnectionComponent := TFDConnection.Create(nil);
  FConnectionComponent.FormatOptions.StrsTrim2Len := True;
  FConnectionComponent.DriverName := ADbConfig.Driver;
  FConnectionComponent.TxOptions.Isolation := xiReadCommitted;
  FConnectionComponent.Params.Add('Database=' + ADbConfig.database);
  FConnectionComponent.Params.Add('User_Name=' + ADbConfig.User);
  FConnectionComponent.Params.Add('Password=' + ADbConfig.Password);
  FConnectionComponent.Params.Add('Protocol=TCPIP');
  FConnectionComponent.Params.Add('Port=' + IntToStr(ADbConfig.Port));
  FConnectionComponent.Params.Add('Server=' + ADbConfig.Host);
  FConnectionComponent.Params.Add('CharacterSet=' + ADbConfig.CharSet);
  FConnectionComponent.Params.Add('DriverID=' + ADbConfig.Driver);
  FConnectionComponent.Params.Add('OpenMode=OpenOrCreate');
  FConnectionComponent.Params.Add('GUIDEndian=Big');
  FConnectionComponent.LoginPrompt := False;
  {$IF DEFINED(INFRA_ORMBR)}
  FDBConnection := TFactoryFireDAC.Create(TFDConnection(FConnectionComponent), dnFirebird);
  {$ENDIF}
end;

destructor TDbEngineFireDAC.Destroy;
begin
  FConnectionComponent.Free;
  inherited;
end;

function TDbEngineFireDAC.InjectConnection(AConn: TComponent;
  ATransactionObject: TObject): IDbEngineFactory;
begin
  if not (AConn is TFDConnection) then
    raise Exception.Create('Invalid connection component instance for FireDAC. '+Self.UnitName);
  FConnectionComponent := TFDConnection(AConn);
end;

function TDbEngineFireDAC.InTransaction: Boolean;
begin
  Result := FConnectionComponent.InTransaction;
end;

function TDbEngineFireDAC.RollbackTx: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.Rollback;
end;

function TDbEngineFireDAC.StartTx: IDbEngineFactory;
begin
  Result := Self;
  FConnectionComponent.StartTransaction;
end;

end.
