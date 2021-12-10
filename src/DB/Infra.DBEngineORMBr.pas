unit Infra.DBEngineORMBr;

interface

uses
  Infra.DBEngine.Contract;

type
  TDbEngineORMBr = class(TInterfacedObject, IDbEngineFactory)
  private

  protected

  public
    constructor Create; 
    destructor Destroy; override;
    
  published

  end;

implementation

{ TDbEngineORMBr }

constructor TDbEngineORMBr.Create;
begin

end;

destructor TDbEngineORMBr.Destroy;
begin

  inherited;
end;

end.
