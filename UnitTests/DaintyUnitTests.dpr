program DaintyUnitTests;

{$R *.res}

uses
  GUITestRunner,
  Dainty in '..\Source\Dainty.pas',
  DaintyTests in 'DaintyTests.pas',
  Dainty.ValueSetter.Default in '..\Source\Dainty.ValueSetter.Default.pas',
  DaintyValueSetterTests in 'DaintyValueSetterTests.pas';

begin
  RunRegisteredTests;
end.
