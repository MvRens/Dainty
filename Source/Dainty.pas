{
  Dainty
    Simple object mapper for Delphi

  Copyright (c) 2020 M. van Renswoude
  https://github.com/MvRens/Dainty


  This is free and unencumbered software released into the public domain.

  Anyone is free to copy, modify, publish, use, compile, sell, or
  distribute this software, either in source code form or as a compiled
  binary, for any purpose, commercial or non-commercial, and by any
  means.

  In jurisdictions that recognize copyright laws, the author or authors
  of this software dedicate any and all copyright interest in the
  software to the public domain. We make this dedication for the benefit
  of the public at large and to the detriment of our heirs and
  successors. We intend this dedication to be an overt act of
  relinquishment in perpetuity of all present and future rights to this
  software under copyright law.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.

  For more information, please refer to <http://unlicense.org/>
}
unit Dainty;

interface
uses
  Data.DB,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,

  Dainty.Converter.Default;


type
  TDaintyReader<T: class> = class;


  /// <summary>
  ///  Annotates a field or property to change it's field name in the DataSet
  ///  as used for the Dainty methods.
  /// </summary>
  FieldName = class(TCustomAttribute)
  private
    FFieldName: string;
  public
    constructor Create(const AFieldName: string);

    property FieldName: string read FFieldName;
  end;


  /// <summary>
  ///  Alias for the FieldName attribute, if you prefer it for clarity.
  ///  They are interchangable, so the same object can be used for both
  ///  row retrieval and insert/update queries.
  /// </summary>
  ParamName = FieldName;


  /// <summary>
  ///  Allows for direct calls to TDainty methods from any DataSet instance, for example
  ///  DataSet.Rows<> or DataSet.GetFirstOrDefault<>.
  /// </summary>
  /// <remarks>
  ///  Because class helpers are not exactly extension methods and only one can apply,
  ///  if you're having conflicts you can call TDainty.Rows<>(DataSet) instead.
  /// </remarks>
  TDaintyDataSetHelper = class helper for TDataSet
  public
    /// <summary>
    ///  Returns a typed enumerable which iterates the DataSet and returns the mapped
    ///  object for each row.
    /// </summary>
    /// <remarks>
    ///  Note that the DataSet is not reset to First and will instead start at the current record.
    /// </remarks>
    function Rows<T: class>: IEnumerable<T>;

    /// <summary>
    ///  Provides access to the reader which allows control over the DataSet loop.
    /// </summary>
    function GetRowReader<T: class>: TDaintyReader<T>;


    /// <summary>
    ///  Returns the current row mapped to the specified class. Throws an exception if no
    ///  row is active.
    /// </summary>
    /// <remarks>
    ///  The caller must Free the returned object.
    /// </remarks>
    function GetFirst<T: class>: T;

    /// <summary>
    ///  Returns the current row mapped to the specified class. Returns nil if no row is active.
    /// </summary>
    /// <remarks>
    ///  The caller must Free the returned object.
    /// </remarks>
    function GetFirstOrDefault<T: class>: T;


    /// <summary>
    ///  Returns the current row mapped to the specified class. Throws an exception if no
    ///  row is active or if more than one row is remaining.
    /// </summary>
    /// <remarks>
    ///  The caller must Free the returned object.
    /// </remarks>
    function GetSingle<T: class>: T;

    /// <summary>
    ///  Returns the current row mapped to the specified class. Returns nil if no row is active
    ///  or if more than one row is remaining.
    /// </summary>
    /// <remarks>
    ///  The caller must Free the returned object.
    /// </remarks>
    function GetSingleOrDefault<T: class>: T;
  end;


  TDaintyParamsMatching = (
    /// <summary>
    ///  All parameters must have a matching member and all members must have a matching parameter.
    ///  This option is the most defensive, and ensures there are no mismatches either way.
    /// </summary>
    dpmExact,

    /// <summary>
    ///  All parameters must have a matching member. Extra members are allowed and ignored.
    ///  This option will ensure the query has no missing parameters.
    /// </summary>
    dpmAllParams,

    /// <summary>
    ///  All members must have a matching parameter. Extra parameters are allowed and will not be set.
    ///  This option can be used if some parameters are set elsewhere in code.
    /// </summary>
    dpmAllMembers,

    /// <summary>
    ///  Match members and parameters, allow missing or extra for either.
    ///  I'm sure you have your reasons.
    /// </summary>
    dpmAny
  );

  /// <summary>
  ///  Allows for direct calls to TDainty methods from any TParams instance, for example
  ///  DataSet.Params.Apply().
  /// </summary>
  /// <remarks>
  ///  Because class helpers are not exactly extension methods and only one can apply,
  ///  if you're having conflicts you can call TDainty.ApplyParams(DataSet.Params, ...) instead.
  /// </remarks>
  TDaintyParamsHelpers = class helper for TParams
  public
    /// <summary>
    ///  Sets the params using the members of AValue.
    /// </summary>
    procedure Apply<T: class>(AValue: T; AMatching: TDaintyParamsMatching = dpmExact);
  end;


  /// <summary>
  ///  Provides row to object mapping functionality. Usually accessed using the TDaintyDataSetHelper.
  /// </summary>
  TDainty = class
  public
    /// <summary>
    ///  Returns a typed enumerable which iterates the DataSet and returns the mapped
    ///  object for each row.
    /// </summary>
    /// <remarks>
    ///  Note that the DataSet is not reset to First and will instead start at the current record.
    /// </remarks>
    class function Rows<T: class>(ADataSet: TDataSet): IEnumerable<T>;

    /// <summary>
    ///  Provides access to the mapper which allows control over the DataSet loop.
    /// </summary>
    class function GetRowReader<T: class>(ADataSet: TDataSet): TDaintyReader<T>;


    /// <summary>
    ///  Returns the current row mapped to the specified class. Throws an exception if no
    ///  row is active.
    /// </summary>
    /// <remarks>
    ///  The caller must Free the returned object.
    /// </remarks>
    class function GetFirst<T: class>(ADataSet: TDataSet): T;

    /// <summary>
    ///  Returns the current row mapped to the specified class. Returns nil if no row is active.
    /// </summary>
    /// <remarks>
    ///  The caller must Free the returned object.
    /// </remarks>
    class function GetFirstOrDefault<T: class>(ADataSet: TDataSet): T;


    /// <summary>
    ///  Returns the current row mapped to the specified class. Throws an exception if no
    ///  row is active or if more than one row is remaining.
    /// </summary>
    /// <remarks>
    ///  The caller must Free the returned object.
    /// </remarks>
    class function GetSingle<T: class>(ADataSet: TDataSet): T;

    /// <summary>
    ///  Returns the current row mapped to the specified class. Returns nil if no row is active
    ///  or if more than one row is remaining.
    /// </summary>
    /// <remarks>
    ///  The caller must Free the returned object.
    /// </remarks>
    class function GetSingleOrDefault<T: class>(ADataSet: TDataSet): T;


    /// <summary>
    ///  Sets the params using the members of AValue.
    /// </summary>
    class procedure ApplyParams<T: class>(AParams: TParams; AValue: T; AMatching: TDaintyParamsMatching = dpmExact);
  end;



  /// <summary>
  ///  Performs the mapping of the current row to the specified type.
  /// </summary>
  TDaintyReader<T: class> = class
  public
    /// <summary>
    ///  Maps the current row to a new object.
    /// </summary>
    /// <remarks>
    ///  The caller must Free the returned object.
    /// </remarks>
    function MapRow: T; virtual; abstract;
  end;


  /// <summary>
  ///  Enumerates over the rows of a DataSet and returns the mapped objects.
  ///  Returned by the Rows<> method.
  /// </summary>
  TDaintyEnumerable<T: class> = class(TInterfacedObject, IEnumerable<T>)
  private
    FReader: TDaintyReader<T>;
    FDataSet: TDataSet;
  public
    constructor Create(AReader: TDaintyReader<T>; ADataSet: TDataSet);
    destructor Destroy; override;

    function GetEnumerator: IEnumerator;
    function GetEnumeratorGeneric: IEnumerator<T>;

    function IEnumerable<T>.GetEnumerator = GetEnumeratorGeneric;
  end;


  /// <summary>
  ///  Internal enumerator returned by TDaintyEnumerable.
  /// </summary>
  /// <remarks>
  ///  For internal use only. It's only in the interface section to prevent "Method of parameterized type declared in interface section must not use local symbol" error.
  /// </remarks>
  TDaintyEnumerator<T: class> = class(TInterfacedObject, IEnumerator<T>)
  private
    FReader: TDaintyReader<T>;
    FDataSet: TDataSet;
    FCurrent: T;
    FOwnsCurrent: Boolean;
    FResetPoint: TArray<Byte>;
  public
    constructor Create(AReader: TDaintyReader<T>; ADataSet: TDataSet);
    destructor Destroy; override;

    function GetCurrent: TObject;
    function GetCurrentGeneric: T;
    function MoveNext: Boolean;
    procedure Reset;

    function IEnumerator<T>.GetCurrent = GetCurrentGeneric;

    function Acquire: T;
  end;


  /// <summary>
  ///  Performs the mapping of the object to parameters.
  /// </summary>
  TDaintyWriter<T: class> = class
  public
    procedure ApplyParams(AValue: T); virtual; abstract;
  end;



  TDaintyFieldReaderProc = reference to procedure(AInstance: TObject; AField: TField);
  TDaintyParamWriterProc = reference to procedure(AInstance: TObject; AParam: TParam);

  TDaintyConverter = record
    FieldReader: TDaintyFieldReaderProc;
    ParamWriter: TDaintyParamWriterProc;
  end;


  TDaintyRttiFieldNameMapping = record
    FieldName: string;
    Converter: TDaintyConverter;

    constructor Create(const AFieldName: string; const AConverter: TDaintyConverter);
  end;

  TDaintyRttiClassMapping = class
  private
    FConstruct: TFunc<TObject>;
    FFieldNameMapping: TList<TDaintyRttiFieldNameMapping>;
  public
    constructor Create(AConstruct: TFunc<TObject>);
    destructor Destroy; override;

    property Construct: TFunc<TObject> read FConstruct;
    property FieldNameMapping: TList<TDaintyRttiFieldNameMapping> read FFieldNameMapping;
  end;

  TDaintyRttiFieldMapping = record
    Field: TField;
    Converter: TDaintyConverter;

    constructor Create(const AField: TField; const AConverter: TDaintyConverter);
  end;


  TDaintyRttiReader<T: class> = class(TDaintyReader<T>)
  private
    FConstruct: TFunc<TObject>;
    FFieldMapping: TList<TDaintyRttiFieldMapping>;
  public
    constructor Create(AClassMapping: TDaintyRttiClassMapping; ADataSet: TDataSet);
    destructor Destroy; override;

    function MapRow: T; override;
  end;


  TDaintyRttiParamMapping = record
    Param: TParam;
    Converter: TDaintyConverter;

    constructor Create(const AParam: TParam; const AConverter: TDaintyConverter);
  end;


  TDaintyRttiWriter<T: class> = class(TDaintyWriter<T>)
  private
    FParamMapping: TList<TDaintyRttiParamMapping>;
  public
    constructor Create(AClassMapping: TDaintyRttiClassMapping; AParams: TParams; AMatching: TDaintyParamsMatching);
    destructor Destroy; override;

    procedure ApplyParams(AValue: T); override;
  end;



  TDaintyRttiMember = class
  private
    FRttiMember: TRttiMember;
  protected
    function GetRttiType: TRttiType; virtual; abstract;
  public
    constructor Create(ARttiMember: TRttiMember);

    function GetValue(AInstance: TObject): TValue; virtual; abstract;
    procedure SetValue(AInstance: TObject; const AValue: TValue); virtual; abstract;

    property RttiMember: TRttiMember read FRttiMember;
    property RttiType: TRttiType read GetRttiType;
  end;


  TDaintyRttiFieldMember = class(TDaintyRttiMember)
  private
    FField: TRttiField;
  protected
    function GetRttiType: TRttiType; override;
  public
    constructor Create(AField: TRttiField);

    function GetValue(AInstance: TObject): TValue; override;
    procedure SetValue(AInstance: TObject; const AValue: TValue); override;
  end;

  TDaintyRttiPropertyMember = class(TDaintyRttiMember)
  private
    FProperty: TRttiProperty;
  protected
    function GetRttiType: TRttiType; override;
  public
    constructor Create(AProperty: TRttiProperty);

    function GetValue(AInstance: TObject): TValue; override;
    procedure SetValue(AInstance: TObject; const AValue: TValue); override;
  end;


  TDaintyRttiConverterFactoryClass = class of TDaintyRttiConverterFactory;

  TDaintyRttiConverterFactory = class
  public
    class function Construct(AMember: TDaintyRttiMember; out AConverter: TDaintyConverter): Boolean; virtual; abstract;
  end;


  TDaintyRttiMapperFactory = class
  private type
    TConverterFactoryRegistration = record
      Factory: TDaintyRttiConverterFactoryClass;
      Priority: Integer;

      constructor Create(AFactory: TDaintyRttiConverterFactoryClass; APriority: Integer);
    end;
  private class var
    SContext: TRttiContext;
    SClassMappingCacheLock: TMultiReadExclusiveWriteSynchronizer;
    SClassMappingCache: TDictionary<Pointer, TDaintyRttiClassMapping>;
    SConverterFactoriesLock: TMultiReadExclusiveWriteSynchronizer;
    SConverterFactories: TList<TConverterFactoryRegistration>;
    SMembers: TObjectList<TDaintyRttiMember>;
  private
    class function GetClassMapping<T: class>: TDaintyRttiClassMapping;
    class function GetFieldName(AMember: TRttiNamedObject): string;
    class function GetConverter(AMember: TRttiMember): TDaintyConverter;
  protected
    class procedure Initialize;
    class procedure Finalize;
  public
    class function ConstructReader<T: class>(ADataSet: TDataSet): TDaintyRttiReader<T>;
    class function ConstructWriter<T: class>(AParams: TParams; AMatching: TDaintyParamsMatching): TDaintyRttiWriter<T>;

    class procedure RegisterConverterFactory(AFactory: TDaintyRttiConverterFactoryClass; APriority: Integer = 0);
    class procedure UnregisterConverterFactory(AFactory: TDaintyRttiConverterFactoryClass);
  end;



implementation
uses
  System.StrUtils,
  System.TypInfo;


{ TDaintyDataSetHelper }
function TDaintyDataSetHelper.Rows<T>: IEnumerable<T>;
begin
  Result := TDainty.Rows<T>(Self);
end;


function TDaintyDataSetHelper.GetRowReader<T>: TDaintyReader<T>;
begin
  Result := TDainty.GetRowReader<T>(Self);
end;


function TDaintyDataSetHelper.GetFirst<T>: T;
begin
  Result := TDainty.GetFirst<T>(Self);
end;


function TDaintyDataSetHelper.GetFirstOrDefault<T>: T;
begin
  Result := TDainty.GetFirstOrDefault<T>(Self);
end;


function TDaintyDataSetHelper.GetSingle<T>: T;
begin
  Result := TDainty.GetSingle<T>(Self);
end;


function TDaintyDataSetHelper.GetSingleOrDefault<T>: T;
begin
  Result := TDainty.GetSingleOrDefault<T>(Self);
end;


{ TDaintyParamsHelpers }
procedure TDaintyParamsHelpers.Apply<T>(AValue: T; AMatching: TDaintyParamsMatching);
begin
  TDainty.ApplyParams<T>(Self, AValue, AMatching);
end;



{ TDainty }
class function TDainty.Rows<T>(ADataSet: TDataSet): IEnumerable<T>;
var
  reader: TDaintyReader<T>;

begin
  reader := GetRowReader<T>(ADataSet);
  Result := TDaintyEnumerable<T>.Create(reader, ADataSet);
end;


class function TDainty.GetRowReader<T>(ADataSet: TDataSet): TDaintyReader<T>;
begin
  Result := TDaintyRttiMapperFactory.ConstructReader<T>(ADataSet);
end;


class function TDainty.GetFirst<T>(ADataSet: TDataSet): T;
var
  enumerator: IEnumerator<T>;

begin
  enumerator := Rows<T>(ADataSet).GetEnumerator;

  if not enumerator.MoveNext then
    raise EDatabaseError.Create('Expected at least 1 record but none found');

  Result := (enumerator as TDaintyEnumerator<T>).Acquire;
end;


class function TDainty.GetFirstOrDefault<T>(ADataSet: TDataSet): T;
var
  enumerator: IEnumerator<T>;

begin
  enumerator := Rows<T>(ADataSet).GetEnumerator;

  if enumerator.MoveNext then
    Result := (enumerator as TDaintyEnumerator<T>).Acquire
  else
    Result := nil;
end;


class function TDainty.GetSingle<T>(ADataSet: TDataSet): T;
var
  enumerator: IEnumerator<T>;

begin
  enumerator := Rows<T>(ADataSet).GetEnumerator;

  if not enumerator.MoveNext then
    raise EDatabaseError.Create('Expected 1 record but none found');

  Result := (enumerator as TDaintyEnumerator<T>).Acquire;

  if enumerator.MoveNext then
  begin
    FreeAndNil(Result);
    raise EDatabaseError.Create('Expected 1 record but more found');
  end;
end;


class function TDainty.GetSingleOrDefault<T>(ADataSet: TDataSet): T;
var
  enumerator: IEnumerator<T>;

begin
  enumerator := Rows<T>(ADataSet).GetEnumerator;

  if not enumerator.MoveNext then
    Exit(nil);

  Result := (enumerator as TDaintyEnumerator<T>).Acquire;

  if enumerator.MoveNext then
    FreeAndNil(Result);
end;


class procedure TDainty.ApplyParams<T>(AParams: TParams; AValue: T; AMatching: TDaintyParamsMatching);
var
  writer: TDaintyWriter<T>;

begin
  writer := TDaintyRttiMapperFactory.ConstructWriter<T>(AParams, AMatching);
  try
    writer.ApplyParams(AValue);
  finally
    FreeAndNil(writer);
  end;
end;



{ TDaintyEnumerable<T> }
constructor TDaintyEnumerable<T>.Create(AReader: TDaintyReader<T>; ADataSet: TDataSet);
begin
  inherited Create;

  FReader := AReader;
  FDataSet := ADataSet;
end;


destructor TDaintyEnumerable<T>.Destroy;
begin
  FreeAndNil(FReader);

  inherited Destroy;
end;


function TDaintyEnumerable<T>.GetEnumerator: IEnumerator;
begin
  Result := GetEnumeratorGeneric;
end;

function TDaintyEnumerable<T>.GetEnumeratorGeneric: IEnumerator<T>;
begin
  Result := TDaintyEnumerator<T>.Create(FReader, FDataSet);
end;


{ TDaintyEnumerator<T> }
constructor TDaintyEnumerator<T>.Create(AReader: TDaintyReader<T>; ADataSet: TDataSet);
begin
  inherited Create;

  FReader := AReader;
  FDataSet := ADataSet;
  FResetPoint := ADataSet.GetBookmark;

  FOwnsCurrent := False;
end;


destructor TDaintyEnumerator<T>.Destroy;
begin
  if FOwnsCurrent then
    FreeAndNil(FCurrent);

  inherited Destroy;
end;


function TDaintyEnumerator<T>.Acquire: T;
begin
  FOwnsCurrent := False;
  Result := FCurrent;
end;


function TDaintyEnumerator<T>.GetCurrent: TObject;
begin
  Result := GetCurrentGeneric;
end;


function TDaintyEnumerator<T>.GetCurrentGeneric: T;
begin
  Result := FCurrent;
end;


function TDaintyEnumerator<T>.MoveNext: Boolean;
begin
  if FDataSet.Eof then
    Exit(False);

  if FOwnsCurrent then
    FreeAndNil(FCurrent);

  FCurrent := FReader.MapRow;
  FOwnsCurrent := True;
  Result := True;

  FDataSet.Next;
end;


procedure TDaintyEnumerator<T>.Reset;
begin
  if FOwnsCurrent then
    FreeAndNil(FCurrent);

  FDataSet.GotoBookmark(FResetPoint);
end;


{ TDaintyRttiMember }
constructor TDaintyRttiMember.Create(ARttiMember: TRttiMember);
begin
  inherited Create;

  FRttiMember := ARttiMember;
end;


{ TDaintyRttiFieldMember }
constructor TDaintyRttiFieldMember.Create(AField: TRttiField);
begin
  inherited Create(AField);

  FField := AField;
end;


function TDaintyRttiFieldMember.GetRttiType: TRttiType;
begin
  Result := FField.FieldType;
end;


function TDaintyRttiFieldMember.GetValue(AInstance: TObject): TValue;
begin
  Result := FField.GetValue(AInstance);
end;


procedure TDaintyRttiFieldMember.SetValue(AInstance: TObject; const AValue: TValue);
begin
  FField.SetValue(AInstance, AValue);
end;


{ TDaintyRttiPropertyMember }
constructor TDaintyRttiPropertyMember.Create(AProperty: TRttiProperty);
begin
  inherited Create(AProperty);

  FProperty := AProperty;
end;


function TDaintyRttiPropertyMember.GetRttiType: TRttiType;
begin
  Result := FProperty.PropertyType;
end;


function TDaintyRttiPropertyMember.GetValue(AInstance: TObject): TValue;
begin
  Result := FProperty.GetValue(AInstance);
end;


procedure TDaintyRttiPropertyMember.SetValue(AInstance: TObject; const AValue: TValue);
begin
  FProperty.SetValue(AInstance, AValue);
end;



{ TDaintyRttiMapperFactory }
class procedure TDaintyRttiMapperFactory.Initialize;
begin
  if Assigned(SClassMappingCache) then
    Exit;

  SContext := TRttiContext.Create;
  SClassMappingCacheLock := TMultiReadExclusiveWriteSynchronizer.Create;
  SClassMappingCache := TObjectDictionary<Pointer, TDaintyRttiClassMapping>.Create([doOwnsValues]);
  SConverterFactoriesLock := TMultiReadExclusiveWriteSynchronizer.Create;
  SConverterFactories := TList<TConverterFactoryRegistration>.Create;
  SMembers := TObjectList<TDaintyRttiMember>.Create;
end;


class procedure TDaintyRttiMapperFactory.RegisterConverterFactory(AFactory: TDaintyRttiConverterFactoryClass; APriority: Integer);
var
  registration: TConverterFactoryRegistration;
  registrationIndex: Integer;

begin
  { Initialization for Dainty.Converter.Default runs before ours, make sure we are initialized }
  Initialize;

  SConverterFactoriesLock.BeginWrite;
  try
    registration := TConverterFactoryRegistration.Create(AFactory, APriority);

    for registrationIndex := 0 to Pred(SConverterFactories.Count) do
      if SConverterFactories[registrationIndex].Priority <= APriority then
      begin
        SConverterFactories.Insert(registrationIndex, registration);
        Exit;
      end;

    SConverterFactories.Add(registration);
  finally
    SConverterFactoriesLock.EndWrite;
  end;
end;


class procedure TDaintyRttiMapperFactory.UnregisterConverterFactory(AFactory: TDaintyRttiConverterFactoryClass);
var
  registrationIndex: Integer;

begin
  SConverterFactoriesLock.BeginWrite;
  try
    for registrationIndex := Pred(SConverterFactories.Count) downto 0 do
      if SConverterFactories[registrationIndex].Factory = AFactory then
        SConverterFactories.Delete(registrationIndex);
  finally
    SConverterFactoriesLock.EndWrite;
  end;
end;


class procedure TDaintyRttiMapperFactory.Finalize;
begin
  FreeAndNil(SMembers);
  FreeAndNil(SConverterFactories);
  FreeAndNil(SConverterFactoriesLock);
  FreeAndNil(SClassMappingCache);
  FreeAndNil(SClassMappingCacheLock);
  SContext.Free;
end;


class function TDaintyRttiMapperFactory.ConstructReader<T>(ADataSet: TDataSet): TDaintyRttiReader<T>;
var
  mapping: TDaintyRttiClassMapping;

begin
  mapping := GetClassMapping<T>;
  Result := TDaintyRttiReader<T>.Create(mapping, ADataSet);
end;


class function TDaintyRttiMapperFactory.ConstructWriter<T>(AParams: TParams; AMatching: TDaintyParamsMatching): TDaintyRttiWriter<T>;
var
  mapping: TDaintyRttiClassMapping;

begin
  mapping := GetClassMapping<T>;
  Result := TDaintyRttiWriter<T>.Create(mapping, AParams, AMatching);
end;


class function TDaintyRttiMapperFactory.GetClassMapping<T>: TDaintyRttiClassMapping;
var
  typeInfoHandle: Pointer;
  classInfo: TRttiType;
  method: TRttiMethod;
  instanceClassType: TClass;
  fieldInfo: TRttiField;
  propertyInfo: TRttiProperty;
  converter: TDaintyConverter;

begin
  SClassMappingCacheLock.BeginRead;
  try
    typeInfoHandle := TypeInfo(T);
    if SClassMappingCache.TryGetValue(typeInfoHandle, Result) then
      Exit;

    SClassMappingCacheLock.BeginWrite;
    try
      { Between the call to BeginWrite and actually acquiring the lock the state
        may have changed. Check again to be sure. }
      if SClassMappingCache.TryGetValue(typeInfoHandle, Result) then
        Exit;

      classInfo := SContext.GetType(typeInfoHandle);
      Result := nil;

      for method in classInfo.GetMethods do
      begin
        if method.IsConstructor and (Length(method.GetParameters) = 0) then
        begin
          instanceClassType := classInfo.AsInstance.MetaclassType;
          Result := TDaintyRttiClassMapping.Create(
            function: TObject
            begin
              Result := method.Invoke(instanceClassType, []).AsObject;
            end);

          Break;
        end;
      end;

      if not Assigned(Result) then
        raise ENoConstructException.Create('A constructor with no parameter is required for Dainty');


      for fieldInfo in classInfo.GetFields do
      begin
        if not (fieldInfo.Visibility in [mvPublic, mvPublished]) then
          Continue;

        Result.FieldNameMapping.Add(TDaintyRttiFieldNameMapping.Create(GetFieldName(fieldInfo), GetConverter(fieldInfo)));
      end;


      for propertyInfo in classInfo.GetProperties do
      begin
        if not (propertyInfo.Visibility in [mvPublic, mvPublished]) then
          Continue;

        if not propertyInfo.IsWritable then
          Continue;

        Result.FieldNameMapping.Add(TDaintyRttiFieldNameMapping.Create(GetFieldName(propertyInfo), GetConverter(propertyInfo)));
      end;

      SClassMappingCache.Add(typeInfoHandle, Result);
    finally
      SClassMappingCacheLock.EndWrite;
    end;
  finally
    SClassMappingCacheLock.EndRead;
  end;
end;


class function TDaintyRttiMapperFactory.GetFieldName(AMember: TRttiNamedObject): string;
var
  attribute: TCustomAttribute;

begin
  for attribute in AMember.GetAttributes do
  begin
    if attribute is FieldName then
      Exit(FieldName(attribute).FieldName);
  end;

  Result := AMember.Name;
end;


class function TDaintyRttiMapperFactory.GetConverter(AMember: TRttiMember): TDaintyConverter;
var
  member: TDaintyRttiMember;
  registration: TConverterFactoryRegistration;
  hasConverter: Boolean;

begin
  if AMember is TRttiField then
    member := TDaintyRttiFieldMember.Create(TRttiField(AMember))
  else if AMember is TRttiProperty then
    member := TDaintyRttiPropertyMember.Create(TRttiProperty(AMember))
  else
    raise EInvalidOpException.CreateFmt('Member type not supported: %s', [AMember.ClassName]);

  hasConverter := False;

  SConverterFactoriesLock.BeginRead;
  try
    for registration in SConverterFactories do
    begin
      if registration.Factory.Construct(member, Result) then
      begin
        hasConverter := True;
        SMembers.Add(member);
        Break;
      end;
    end;
  finally
    SConverterFactoriesLock.EndRead;
  end;

  if not hasConverter then
  begin
    FreeAndNil(member);
    raise ENotSupportedException.CreateFmt('Member %s has unsupported type for Dainty: %d', [AMember.Name, Ord(member.RttiType.TypeKind)]);
  end;
end;


{ TDaintyRttiMapperFactory.TConverterFactoryRegistration }
constructor TDaintyRttiMapperFactory.TConverterFactoryRegistration.Create(AFactory: TDaintyRttiConverterFactoryClass; APriority: Integer);
begin
  Factory := AFactory;
  Priority := APriority;
end;


{ TDaintyRttiReader<T> }
constructor TDaintyRttiReader<T>.Create(AClassMapping: TDaintyRttiClassMapping; ADataSet: TDataSet);
var
  fieldNameMapping: TDaintyRttiFieldNameMapping;

begin
  inherited Create;

  FConstruct := AClassMapping.Construct;
  FFieldMapping := TList<TDaintyRttiFieldMapping>.Create;

  for fieldNameMapping in AClassMapping.FieldNameMapping do
    FFieldMapping.Add(TDaintyRttiFieldMapping.Create(ADataSet.FieldByName(fieldNameMapping.FieldName), fieldNameMapping.Converter));
end;


destructor TDaintyRttiReader<T>.Destroy;
begin
  FreeAndNil(FFieldMapping);

  inherited Destroy;
end;


function TDaintyRttiReader<T>.MapRow: T;
var
  fieldMapping: TDaintyRttiFieldMapping;

begin
  Result := FConstruct() as T;

  for fieldMapping in FFieldMapping do
    fieldMapping.Converter.FieldReader(Result, fieldMapping.Field);
end;


{ TDaintyRttiWriter<T> }
constructor TDaintyRttiWriter<T>.Create(AClassMapping: TDaintyRttiClassMapping; AParams: TParams; AMatching: TDaintyParamsMatching);
var
  fieldNameMapping: TDaintyRttiFieldNameMapping;
  remainingParams: TList<TParam>;
  paramIndex: Integer;
  param: TParam;
  paramNames: string;

begin
  inherited Create;

  FParamMapping := TList<TDaintyRttiParamMapping>.Create;
  try
    remainingParams := TList<TParam>.Create;
    try
      for paramIndex := 0 to Pred(AParams.Count) do
        remainingParams.Add(AParams[paramIndex]);


      for fieldNameMapping in AClassMapping.FieldNameMapping do
      begin
        param := AParams.FindParam(fieldNameMapping.FieldName);
        if Assigned(param) then
        begin
          remainingParams.Remove(param);
          FParamMapping.Add(TDaintyRttiParamMapping.Create(param, fieldNameMapping.Converter));
        end else if AMatching in [dpmExact, dpmAllMembers] then
          raise EProgrammerNotFound.CreateFmt('Parameter not found: %s', [fieldNameMapping.FieldName]);
      end;


      { Check if all parameters have a corresponding member }
      if (AMatching in [dpmExact, dpmAllParams]) and (remainingParams.Count > 0) then
      begin
        paramNames := '';
        for param in remainingParams do
          paramNames := paramNames + IfThen(Length(paramNames) = 0, '', ', ') + param.Name;

        raise EProgrammerNotFound.CreateFmt('The following parameters do not have a corresponding member: %s', [paramNames]);
      end;
    finally
      FreeAndNil(remainingParams);
    end;
  except
    FreeAndNil(FParamMapping);
    raise;
  end;
end;


destructor TDaintyRttiWriter<T>.Destroy;
begin
  FreeAndNil(FParamMapping);

  inherited Destroy;
end;


procedure TDaintyRttiWriter<T>.ApplyParams(AValue: T);
var
  paramMapping: TDaintyRttiParamMapping;

begin
  for paramMapping in FParamMapping do
    paramMapping.Converter.ParamWriter(AValue, paramMapping.Param);
end;


{ TDaintyRttiFieldNameMapping }
constructor TDaintyRttiFieldNameMapping.Create(const AFieldName: string; const AConverter: TDaintyConverter);
begin
  FieldName := AFieldName;
  Converter := AConverter;
end;


{ TDaintyRttiFieldMapping }
constructor TDaintyRttiFieldMapping.Create(const AField: TField; const AConverter: TDaintyConverter);
begin
  Field := AField;
  Converter := AConverter;
end;


{ TDaintyRttiParamMapping }
constructor TDaintyRttiParamMapping.Create(const AParam: TParam; const AConverter: TDaintyConverter);
begin
  Param := AParam;
  Converter := AConverter;
end;


{ TDaintyRttiClassMapping }
constructor TDaintyRttiClassMapping.Create(AConstruct: TFunc<TObject>);
begin
  inherited Create;

  FConstruct := AConstruct;
  FFieldNameMapping := TList<TDaintyRttiFieldNameMapping>.Create;
end;


destructor TDaintyRttiClassMapping.Destroy;
begin
  FreeAndNil(FFieldNameMapping);

  inherited Destroy;
end;


{ FieldName }
constructor FieldName.Create(const AFieldName: string);
begin
  inherited Create;

  FFieldName := AFieldName;
end;


initialization
  TDaintyRttiMapperFactory.Initialize;

finalization
  TDaintyRttiMapperFactory.Finalize;

end.
