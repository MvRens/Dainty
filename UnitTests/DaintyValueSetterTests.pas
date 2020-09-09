unit DaintyValueSetterTests;

interface
uses
  Data.DB,
  DataSnap.DBClient,
  MidasLib,
  TestFramework,

  Dainty;


type
  TDaintyValueSetterTest = class(TTestCase)
  private
    FDataSet: TClientDataSet;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    property DataSet: TClientDataSet read FDataSet;
  published
    procedure CustomRecordMapping;
    procedure GenericCustomRecordMapping;
  end;


implementation
uses
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  System.Variants;


{ TDaintyValueSetterTest }
procedure TDaintyValueSetterTest.SetUp;
begin
  inherited SetUp;

  FDataSet := TClientDataSet.Create(nil);
end;


procedure TDaintyValueSetterTest.TearDown;
begin
  FreeAndNil(FDataSet);

  inherited TearDown;
end;


type
  TCustomRecord = record
    Value: string;
  end;

  TCustomRecordRow = class
    StringField: TCustomRecord;
  end;


  { Mimics our proprietary implementation of generic nullables, which is based on:
    https://community.embarcadero.com/blogs/entry/a-andquotnullableandquot-post-38869 }
  TGenericCustomRecord<T> = record
    Value: T;
  end;

  TGenericCustomRecordRow = class
    StringField: TGenericCustomRecord<string>;
  end;


  TCustomRecordValueSetterFactory = class(TDaintyAbstractValueSetterFactory)
  public
    class function Construct(AMember: TDaintyRttiMember): TDaintyValueSetter; override;
  end;


{ TCustomRecordValueSetterFactory }
class function TCustomRecordValueSetterFactory.Construct(AMember: TDaintyRttiMember): TDaintyValueSetter;
begin
  if AMember.RttiType.TypeKind <> tkRecord then
    Exit(nil);

  if AMember.RttiType.Handle = TypeInfo(TCustomRecord) then
  begin
    Result :=
      procedure(AInstance: TObject; AField: TField)
      var
        customRecord: TCustomRecord;

      begin
        customRecord.Value := AField.AsString;
        AMember.SetValue(AInstance, TValue.From(customRecord));
      end;

  { Unfortunately I have not found a way to make this generic, if you do let me know!
    The workaround is to handle all types you want to support explicitly, which is
    good enough for our use case with nullable implementations. }
  end else if AMember.RttiType.Handle = TypeInfo(TGenericCustomRecord<string>) then
  begin
    Result :=
      procedure(AInstance: TObject; AField: TField)
      var
        value: TGenericCustomRecord<string>;

      begin
        value.Value := AField.AsString;
        AMember.SetValue(AInstance, TValue.From(value));
      end;
  end;
end;


procedure TDaintyValueSetterTest.CustomRecordMapping;
var
  row: TCustomRecordRow;

begin
  DataSet.FieldDefs.Add('STRINGFIELD', ftString, 50);
  DataSet.CreateDataSet;
  DataSet.LogChanges := False;

  DataSet.Append;
  DataSet.FieldByName('STRINGFIELD').AsString := 'Hello world!';
  DataSet.Post;


  TDaintyRttiMapperFactory.RegisterValueSetterFactory(TCustomRecordValueSetterFactory, 1);
  try
    DataSet.First;
    row := DataSet.GetFirst<TCustomRecordRow>;

    CheckEquals('Hello world!', row.StringField.Value);
  finally
    TDaintyRttiMapperFactory.UnregisterValueSetterFactory(TCustomRecordValueSetterFactory);
  end;
end;


procedure TDaintyValueSetterTest.GenericCustomRecordMapping;
var
  row: TGenericCustomRecordRow;

begin
  DataSet.FieldDefs.Add('STRINGFIELD', ftString, 50);
  DataSet.CreateDataSet;
  DataSet.LogChanges := False;

  DataSet.Append;
  DataSet.FieldByName('STRINGFIELD').AsString := 'Hello world!';
  DataSet.Post;


  TDaintyRttiMapperFactory.RegisterValueSetterFactory(TCustomRecordValueSetterFactory, 1);
  try
    DataSet.First;
    row := DataSet.GetFirst<TGenericCustomRecordRow>;

    CheckEquals('Hello world!', row.StringField.Value);
  finally
    TDaintyRttiMapperFactory.UnregisterValueSetterFactory(TCustomRecordValueSetterFactory);
  end;
end;


initialization
  RegisterTest(TDaintyValueSetterTest.Suite);

end.
