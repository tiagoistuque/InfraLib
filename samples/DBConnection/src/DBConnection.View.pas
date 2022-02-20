unit DBConnection.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, DB,

  Infra.DBEngine,
  Infra.QueryEngine;

type
  TForm1 = class(TForm)
    Button1: TButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FConfig: IDbEngineConfig;
    FDataSet: TDataSet;
    FEngine: IDBEngine;
    FQuery: IQueryEngine;
    procedure _SetupConfig;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.Button1Click(Sender: TObject);
begin
  FEngine.OpenSQL('SELECT CURRENT_TIMESTAMP as DATAHORA, CURRENT_USER, CURRENT_CONNECTION FROM RDB$DATABASE', FDataSet);
  DataSource1.DataSet := FDataSet;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FQuery.Reset
    .Add('SELECT')
    .Add('CURRENT_TIMESTAMP as DATAHORA, CURRENT_USER, CURRENT_CONNECTION')
    .Add('FROM RDB$DATABASE')
    .Open;
  DataSource1.DataSet := FQuery.DataSet;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  _SetupConfig;
  FEngine := TDBEngine.New(FConfig);
  FQuery := TQueryEngine.New(FEngine);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(FDataSet) then
    FreeAndNil(FDataSet);
  FEngine := nil;
end;

procedure TForm1._SetupConfig;
begin
  FConfig := TDBConfigFactory.CreateConfig(TTypeConfig.IniFile);
  FConfig
    .Driver(TDbDriver.Firebird)
    .Host('localhost')
    .Port(3053)
    .Database(ExtractFilePath(ParamStr(0)) + 'data\TESTE.FDB')
    .CharSet('UTF8')
    .User('SYSDBA')
    .Password('masterkey');
end;

end.
