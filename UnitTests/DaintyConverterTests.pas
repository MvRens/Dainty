unit DaintyConverterTests;

interface
uses
  Data.DB,
  DataSnap.DBClient,
  MidasLib,
  TestFramework,

  Dainty;


type
  TDaintyConverterTest = class(TTestCase)
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


{ TDaintyConverterTest }
procedure TDaintyConverterTest.SetUp;
begin
  inherited SetUp;

  FDataSet := TClientDataSet.Create(nil);
end;


procedure TDaintyConverterTest.TearDown;
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


  TCustomRecordValueSetterFactory = class(TDaintyRttiConverterFactory)
  public
    class function Construct(AMember: TDaintyRttiMember; out AConverter: TDaintyConverter): Boolean; override;
  end;


{ TCustomRecordValueSetterFactory }
class function TCustomRecordValueSetterFactory.Construct(AMember: TDaintyRttiMember; out AConverter: TDaintyConverter): Boolean;
begin
  Result := False;
  if AMember.RttiType.TypeKind <> tkRecord then
    Exit;

  if AMember.RttiType.Handle = TypeInfo(TCustomRecord) then
  begin
    Result := True;

    AConverter.FieldReader :=
      procedure(AInstance: TObject; AField: TField)
      var
        customRecord: TCustomRecord;

      begin
        customRecord.Value := AField.AsString;
        AMember.SetValue(AInstance, TValue.From(customRecord));
      end;

    AConverter.ParamWriter :=
      procedure(AInstance: TObject; AParam: TParam)
      var
        customRecord: TCustomRecord;

      begin
        customRecord := AMember.GetValue(AInstance).AsType<TCustomRecord>;
        AParam.AsString := customRecord.Value;
      end;

  { Unfortunately I have not found a way to make this generic, if you do let me know!
    The workaround is to handle all types you want to support explicitly, which is
    good enough for our use case with nullable implementations. }
  end else if AMember.RttiType.Handle = TypeInfo(TGenericCustomRecord<string>) then
  begin
    Result := True;

    AConverter.FieldReader :=
      procedure(AInstance: TObject; AField: TField)
      var
        value: TGenericCustomRecord<string>;

      begin
        value.Value := AField.AsString;
        AMember.SetValue(AInstance, TValue.From(value));
      end;

    AConverter.ParamWriter :=
      procedure(AInstance: TObject; AParam: TParam)
      var
        value: TGenericCustomRecord<string>;

      begin
        value := AMember.GetValue(AInstance).AsType<TGenericCustomRecord<string>>;
        AParam.AsString := value.Value;
      end;
  end;
end;


procedure TDaintyConverterTest.CustomRecordMapping;
var
  row: TCustomRecordRow;

begin
  DataSet.FieldDefs.Add('STRINGFIELD', ftString, 50);
  DataSet.CreateDataSet;
  DataSet.LogChanges := False;

  DataSet.Append;
  DataSet.FieldByName('STRINGFIELD').AsString := 'Hello world!';
  DataSet.Post;


  TDaintyRttiMapperFactory.RegisterConverterFactory(TCustomRecordValueSetterFactory, 1);
  try
    DataSet.First;
    row := DataSet.GetFirst<TCustomRecordRow>;
    try
      CheckEquals('Hello world!', row.StringField.Value);
    finally
      FreeAndNil(row);
    end;
  finally
    TDaintyRttiMapperFactory.UnregisterConverterFactory(TCustomRecordValueSetterFactory);
  end;
end;


procedure TDaintyConverterTest.GenericCustomRecordMapping;
var
  row: TGenericCustomRecordRow;

begin
  DataSet.FieldDefs.Add('STRINGFIELD', ftString, 50);
  DataSet.CreateDataSet;
  DataSet.LogChanges := False;

  DataSet.Append;
  DataSet.FieldByName('STRINGFIELD').AsString := 'Hello world!';
  DataSet.Post;


  TDaintyRttiMapperFactory.RegisterConverterFactory(TCustomRecordValueSetterFactory, 1);
  try
    DataSet.First;
    row := DataSet.GetFirst<TGenericCustomRecordRow>;
    try
      CheckEquals('Hello world!', row.StringField.Value);
    finally
      FreeAndNil(row);
    end;
  finally
    TDaintyRttiMapperFactory.UnregisterConverterFactory(TCustomRecordValueSetterFactory);
  end;
end;


initialization
  RegisterTest(TDaintyConverterTest.Suite);

end.
