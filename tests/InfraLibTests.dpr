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
  Infra.SysInfo in '..\src\Infra.SysInfo.pas',
  Infra.QueryEngine.Abstract in '..\src\Query\Infra.QueryEngine.Abstract.pas',
  Infra.QueryEngine.Contract in '..\src\Query\Infra.QueryEngine.Contract.pas',
  Infra.QueryEngine.DBExpress in '..\src\Query\Infra.QueryEngine.DBExpress.pas',
  Infra.QueryEngine.FireDAC in '..\src\Query\Infra.QueryEngine.FireDAC.pas',
  Infra.QueryEngine in '..\src\Query\Infra.QueryEngine.pas',
  Infra.DML.Contracts in '..\src\DB\Infra.DML.Contracts.pas',
  Infra.DML.GeneratorAbstract in '..\src\DB\Infra.DML.GeneratorAbstract.pas',
  Infra.DBDriver.Register in '..\src\DB\Infra.DBDriver.Register.pas',
  Infra.DML.Generator.Firebird in '..\src\DB\Infra.DML.Generator.Firebird.pas',
  Infra.DML.Generator.MSSQL in '..\src\DB\Infra.DML.Generator.MSSQL.pas',
  InfraLib.Tests.QueryEngine in 'src\InfraLib.Tests.QueryEngine.pas',
  Infra.DML.Generator.MSAccess in '..\src\DB\Infra.DML.Generator.MSAccess.pas',
  Infra.QueryEngine.Zeos in '..\src\Query\Infra.QueryEngine.Zeos.pas',
  Infra.DBEngine.Trace.Types in '..\src\DB\Infra.DBEngine.Trace.Types.pas',
  Infra.DBEngine.Trace.Provider in '..\src\DB\Infra.DBEngine.Trace.Provider.pas',
  Infra.DBEngine.Trace.Utils in '..\src\DB\Infra.DBEngine.Trace.Utils.pas',
  PerlRegEx in '..\src\PerlRegEx\PerlRegEx.pas',
  Infra.System.RegularExpressions in '..\src\Infra.System.RegularExpressions.pas',
  pcre in '..\src\PerlRegEx\pcre.pas',
  Infra.DBEngine.Trace.Thread in '..\src\DB\Infra.DBEngine.Trace.Thread.pas',
  Infra.DBEngine.Trace.Manager in '..\src\DB\Infra.DBEngine.Trace.Manager.pas',
  Infra.DBEngine.Trace.Provider.LogFile in '..\src\DB\Infra.DBEngine.Trace.Provider.LogFile.pas',
  Infra.DBEngine.Trace in '..\src\DB\Infra.DBEngine.Trace.pas',
  Infra.DBEngine.Context in '..\src\DB\Infra.DBEngine.Context.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
  ReportMemoryLeaksOnShutdown := True;
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
