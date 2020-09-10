program DaintyUnitTests;

{$R *.res}

uses
  GUITestRunner,
  Dainty in '..\Source\Dainty.pas',
  DaintyFieldsTests in 'DaintyFieldsTests.pas',
  Dainty.Converter.Default in '..\Source\Dainty.Converter.Default.pas',
  DaintyConverterTests in 'DaintyConverterTests.pas',
  DaintyParamsTests in 'DaintyParamsTests.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  RunRegisteredTests;
end.
