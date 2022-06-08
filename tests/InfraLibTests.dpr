program InfraLibTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  InfraLib.Tests.DbEngine in 'src\InfraLib.Tests.DbEngine.pas',
  Infra.DBConfig.EnvironmentVar in '..\src\DB\Infra.DBConfig.EnvironmentVar.pas',
  Infra.DBConfig.IniFile in '..\src\DB\Infra.DBConfig.IniFile.pas',
  Infra.DBConfig.Memory in '..\src\DB\Infra.DBConfig.Memory.pas',
  Infra.DBConfig in '..\src\DB\Infra.DBConfig.pas',
  Infra.DBEngine.Abstract in '..\src\DB\Infra.DBEngine.Abstract.pas',
  Infra.DBEngine.Contract in '..\src\DB\Infra.DBEngine.Contract.pas',
  Infra.DBEngine.DBExpress in '..\src\DB\Infra.DBEngine.DBExpress.pas',
  Infra.DBEngine.FireDAC in '..\src\DB\Infra.DBEngine.FireDAC.pas',
  Infra.DBEngine in '..\src\DB\Infra.DBEngine.pas',
  Infra.DBEngine.Zeos in '..\src\DB\Infra.DBEngine.Zeos.pas',
  Infra.Commons in '..\src\Infra.Commons.pas',
  Infra.Files in '..\src\Infra.Files.pas',
  Infra.SysInfo in '..\src\Infra.SysInfo.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
