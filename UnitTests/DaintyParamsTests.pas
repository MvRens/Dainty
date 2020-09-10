unit DaintyParamsTests;

interface
uses
  Data.DB,
  TestFramework,

  Dainty;


type
  TDaintyParamsTest = class(TTestCase)
  private
    FParams: TParams;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    property Params: TParams read FParams;
  published
    procedure SimpleTypes;

    // #ToDo1 -oMvR: 10-9-2020: tests for various matching types
  end;


implementation
uses
  System.SysUtils;


{ TDaintyParamsTest }
procedure TDaintyParamsTest.SetUp;
begin
  inherited SetUp;

  FParams := TParams.Create();
end;


procedure TDaintyParamsTest.TearDown;
begin
  FreeAndNil(FParams);

  inherited TearDown;
end;



type
  TSimpleTypesParams = class
    StringParam: string;
    IntegerParam: Integer;
    DateTimeParam: TDateTime;
    BooleanParam: Boolean;
    FloatParam: Double;
  end;


procedure TDaintyParamsTest.SimpleTypes;
var
  simpleTypesParams: TSimpleTypesParams;

begin
  Params.AddParameter.Name := 'STRINGPARAM';
  Params.AddParameter.Name := 'INTEGERPARAM';
  Params.AddParameter.Name := 'DATETIMEPARAM';
  Params.AddParameter.Name := 'BOOLEANPARAM';
  Params.AddParameter.Name := 'FLOATPARAM';

  simpleTypesParams := TSimpleTypesParams.Create;
  try
    simpleTypesParams.StringParam := 'Hello world!';
    simpleTypesParams.IntegerParam := 42;
    simpleTypesParams.DateTimeParam := EncodeDate(2020, 9, 7);
    simpleTypesParams.BooleanParam := True;
    simpleTypesParams.FloatParam := 3.1415;

    Params.Apply(simpleTypesParams);

    CheckEquals('Hello world!', Params.ParamByName('STRINGPARAM').AsString, 'StringParam');
    CheckEquals(42, Params.ParamByName('INTEGERPARAM').AsInteger, 'IntegerParam');
    CheckEquals(EncodeDate(2020, 9, 7), Params.ParamByName('DATETIMEPARAM').AsDate, 0.9, 'DateTimeParam');
    CheckEquals(True, Params.ParamByName('BOOLEANPARAM').AsBoolean, 'BooleanParam');
    CheckEquals(3.1415, Params.ParamByName('FLOATPARAM').AsFloat, 0.0001, 'FloatParam');
  finally
    FreeAndNil(simpleTypesParams);
  end;
end;


initialization
  RegisterTest(TDaintyParamsTest.Suite);

end.

