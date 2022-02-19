program DBConnection;

uses
  Vcl.Forms,
  DBConnection.View in 'src\DBConnection.View.pas' {Form1},
  Infra.QueryEngine.Contract in '..\..\src\Query\Infra.QueryEngine.Contract.pas',
  Infra.QueryEngine in '..\..\src\Query\Infra.QueryEngine.pas',
  Infra.QueryEngine.Abstract in '..\..\src\Query\Infra.QueryEngine.Abstract.pas',
  Infra.QueryEngine.FireDAC in '..\..\src\Query\Infra.QueryEngine.FireDAC.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
