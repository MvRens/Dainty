unit DaintyFieldsTests;

interface
uses
  Data.DB,
  Datasnap.DBClient,
  MidasLib,
  TestFramework,

  Dainty;


type
  TDaintyFieldsTest = class(TTestCase)
  private
    FDataSet: TClientDataSet;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure FillTestData(ARowCount: Integer);

    property DataSet: TClientDataSet read FDataSet;
  published
    procedure SimpleTypes;

    procedure GetFirst;
    procedure GetFirstMultipleRows;
    procedure GetFirstNoData;
    procedure GetFirstOrDefault;

    procedure GetSingle;
    procedure GetSingleMultipleRows;
    procedure GetSingleNoData;
    procedure GetSingleOrDefaultMultipleRows;
    procedure GetSingleOrDefaultNoData;

    procedure FieldNameAttribute;
    procedure FieldNameAttributeProperty;
  end;


implementation
uses
  System.SysUtils;


{ TDaintyFieldsTest }
procedure TDaintyFieldsTest.SetUp;
begin
  inherited SetUp;

  FDataSet := TClientDataSet.Create(nil);
end;


procedure TDaintyFieldsTest.TearDown;
begin
  FreeAndNil(FDataSet);

  inherited TearDown;
end;



type
  TSimpleTypesRecord = class
    StringField: string;
    IntegerField: Integer;
    DateTimeField: TDateTime;
    BooleanField: Boolean;
    FloatField: Double;
  end;


procedure TDaintyFieldsTest.SimpleTypes;

  procedure AddRow(const AStringValue: string; AIntegerValue: Integer; ADateTimeValue: TDateTime; ABooleanValue: Boolean; AFloatValue: Double);
  begin
    DataSet.Append;
    DataSet.FieldByName('STRINGFIELD').AsString := AStringValue;
    DataSet.FieldByName('INTEGERFIELD').AsInteger := AIntegerValue;
    DataSet.FieldByName('DATETIMEFIELD').AsDateTime := ADateTimeValue;
    DataSet.FieldByName('BOOLEANFIELD').AsBoolean := ABooleanValue;
    DataSet.FieldByName('FLOATFIELD').AsFloat := AFloatValue;
    DataSet.Post;
  end;

var
  row: TSimpleTypesRecord;
  rowIndex: Integer;

begin
  DataSet.FieldDefs.Add('STRINGFIELD', ftString, 50);
  DataSet.FieldDefs.Add('INTEGERFIELD', ftInteger);
  DataSet.FieldDefs.Add('DATETIMEFIELD', ftDate);
  DataSet.FieldDefs.Add('BOOLEANFIELD', ftBoolean);
  DataSet.FieldDefs.Add('FLOATFIELD', ftFloat);
  DataSet.CreateDataSet;
  DataSet.LogChanges := False;

  AddRow('Hello', 42, EncodeDate(2020, 9, 7), True, 3.1415);
  AddRow('world!', 69, EncodeDate(2006, 1, 1), False, 1.618);


  DataSet.First;
  rowIndex := 0;

  for row in DataSet.Rows<TSimpleTypesRecord> do
  begin
    case rowIndex of
      0:
        begin
          CheckEquals('Hello', row.StringField, 'StringField');
          CheckEquals(42, row.IntegerField, 'IntegerField');
          CheckEquals(EncodeDate(2020, 9, 7), row.DateTimeField, 0.9, 'DateTimeField');
          CheckEquals(True, row.BooleanField, 'BooleanField');
          CheckEquals(3.1415, row.FloatField, 0.0001, 'FloatField');
        end;

      1:
        begin
          CheckEquals('world!', row.StringField);
          CheckEquals(69, row.IntegerField, 'IntegerField');
          CheckEquals(EncodeDate(2006, 1, 1), row.DateTimeField, 0.9, 'DateTimeField');
          CheckEquals(False, row.BooleanField, 'BooleanField');
          CheckEquals(1.618, row.FloatField, 0.0001, 'FloatField');
        end;
    end;

    Inc(rowIndex);
  end;
end;



type
  TTestRow = class
    RowNumber: Integer;
  end;


procedure TDaintyFieldsTest.FillTestData(ARowCount: Integer);
var
  rowNumber: Integer;

begin
  DataSet.FieldDefs.Add('ROWNUMBER', ftInteger);
  DataSet.CreateDataSet;
  DataSet.LogChanges := False;

  for rowNumber := 1 to ARowCount do
  begin
    DataSet.Append;
    DataSet.FieldByName('ROWNUMBER').AsInteger := rowNumber;
    DataSet.Post;
  end;

  DataSet.First;
end;


procedure TDaintyFieldsTest.GetFirst;
var
  row: TTestRow;

begin
  FillTestData(1);
  row := DataSet.GetFirst<TTestRow>;
  try
    CheckEquals(1, row.RowNumber);
  finally
    FreeAndNil(row);
  end;
end;


procedure TDaintyFieldsTest.GetFirstMultipleRows;
var
  row: TTestRow;

begin
  FillTestData(2);
  row := DataSet.GetFirst<TTestRow>;
  try
    CheckEquals(1, row.RowNumber);
  finally
    FreeAndNil(row);
  end;
end;


procedure TDaintyFieldsTest.GetFirstNoData;
begin
  FillTestData(0);
  ExpectedException := EDatabaseError;
  DataSet.GetFirst<TTestRow>;
end;


procedure TDaintyFieldsTest.GetFirstOrDefault;
var
  row: TTestRow;

begin
  FillTestData(0);
  row := DataSet.GetFirstOrDefault<TTestRow>;
  CheckNull(row);
end;


procedure TDaintyFieldsTest.GetSingle;
var
  row: TTestRow;

begin
  FillTestData(1);
  row := DataSet.GetSingle<TTestRow>;
  try
    CheckEquals(1, row.RowNumber);
  finally
    FreeAndNil(row);
  end;
end;


procedure TDaintyFieldsTest.GetSingleMultipleRows;
begin
  ExpectedException := EDatabaseError;
  FillTestData(2);
  DataSet.GetSingle<TTestRow>;
end;


procedure TDaintyFieldsTest.GetSingleNoData;
begin
  ExpectedException := EDatabaseError;
  FillTestData(0);
  DataSet.GetSingle<TTestRow>;
end;


procedure TDaintyFieldsTest.GetSingleOrDefaultMultipleRows;
var
  row: TTestRow;

begin
  FillTestData(2);
  row := DataSet.GetSingleOrDefault<TTestRow>;
  try
    CheckNull(row);
  finally
    FreeAndNil(row);
  end;
end;


procedure TDaintyFieldsTest.GetSingleOrDefaultNoData;
var
  row: TTestRow;

begin
  FillTestData(0);
  row := DataSet.GetSingleOrDefault<TTestRow>;
  CheckNull(row);
end;



type
  TAttributeTestRow = class
    [FieldName('STRING_FIELD')]
    StringField: string;
  end;


procedure TDaintyFieldsTest.FieldNameAttribute;
var
  row: TAttributeTestRow;

begin
  DataSet.FieldDefs.Add('STRING_FIELD', ftString, 50);
  DataSet.CreateDataSet;
  DataSet.LogChanges := False;

  DataSet.Append;
  DataSet.FieldByName('STRING_FIELD').AsString := 'Hello world!';
  DataSet.Post;

  row := DataSet.GetFirst<TAttributeTestRow>;
  try
    CheckEquals('Hello world!', row.StringField);
  finally
    FreeAndNil(row);
  end;
end;



type
  TPropertyAttributeTestRow = class
  private
    FStringField: string;
  public
    [FieldName('STRING_FIELD')]
    property StringField: string read FStringField write FStringField;
  end;


procedure TDaintyFieldsTest.FieldNameAttributeProperty;
var
  row: TPropertyAttributeTestRow;

begin
  DataSet.FieldDefs.Add('STRING_FIELD', ftString, 50);
  DataSet.CreateDataSet;
  DataSet.LogChanges := False;

  DataSet.Append;
  DataSet.FieldByName('STRING_FIELD').AsString := 'Hello world!';
  DataSet.Post;

  row := DataSet.GetFirst<TPropertyAttributeTestRow>;
  try
    CheckEquals('Hello world!', row.StringField);
  finally
    FreeAndNil(row);
  end;
end;




initialization
  RegisterTest(TDaintyFieldsTest.Suite);

end.

