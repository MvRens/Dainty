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

  Dainty.ValueSetter.Default;


type
  TDaintyMapper<T: class> = class;


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
    function Rows<T: class>: TEnumerable<T>;

    /// <summary>
    ///  Provides access to the mapper which allows control over the DataSet loop.
    /// </summary>
    function GetMapper<T: class>: TDaintyMapper<T>;


    /// <summary>
    ///  Returns the current row mapped to the specified class. Throws an exception if no
    ///  row is active.
    /// </summary>
    function GetFirst<T: class>: T;

    /// <summary>
    ///  Returns the current row mapped to the specified class. Returns the value of
    ///  ADefault if no row is active.
    /// </summary>
    function GetFirstOrDefault<T: class>(const ADefault: T): T;


    /// <summary>
    ///  Returns the current row mapped to the specified class. Throws an exception if no
    ///  row is active or if more than one row is remaining.
    /// </summary>
    function GetSingle<T: class>: T;

    /// <summary>
    ///  Returns the current row mapped to the specified class. Returns the value of
    ///  ADefault if no row is active or if more than one row is remaining.
    /// </summary>
    function GetSingleOrDefault<T: class>(const ADefault: T): T;
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
    class function Rows<T: class>(ADataSet: TDataSet): TEnumerable<T>;

    /// <summary>
    ///  Provides access to the mapper which allows control over the DataSet loop.
    /// </summary>
    class function GetMapper<T: class>(ADataSet: TDataSet): TDaintyMapper<T>;


    /// <summary>
    ///  Returns the current row mapped to the specified class. Throws an exception if no
    ///  row is active.
    /// </summary>
    class function GetFirst<T: class>(ADataSet: TDataSet): T;

    /// <summary>
    ///  Returns the current row mapped to the specified class. Returns the value of
    ///  ADefault if no row is active.
    /// </summary>
    class function GetFirstOrDefault<T: class>(ADataSet: TDataSet; const ADefault: T): T;


    /// <summary>
    ///  Returns the current row mapped to the specified class. Throws an exception if no
    ///  row is active or if more than one row is remaining.
    /// </summary>
    class function GetSingle<T: class>(ADataSet: TDataSet): T;

    /// <summary>
    ///  Returns the current row mapped to the specified class. Returns the value of
    ///  ADefault if no row is active or if more than one row is remaining.
    /// </summary>
    class function GetSingleOrDefault<T: class>(ADataSet: TDataSet; const ADefault: T): T;
  end;



  /// <summary>
  ///  Performs the mapping of the current row to the specified type.
  /// </summary>
  TDaintyMapper<T: class> = class
  public
    function MapRow: T; virtual; abstract;
  end;


  /// <summary>
  ///  Enumerates over the rows of a DataSet and returns the mapped objects.
  ///  Returned by the Rows<> method.
  /// </summary>
  TDaintyEnumerable<T: class> = class(TEnumerable<T>)
  private
    FMapper: TDaintyMapper<T>;
    FDataSet: TDataSet;
  protected
    function DoGetEnumerator: TEnumerator<T>; override;
  public
    constructor Create(AMapper: TDaintyMapper<T>; ADataSet: TDataSet);
  end;


  /// <summary>
  ///  Internal enumerator returned by TDaintyEnumerable.
  /// </summary>
  /// <remarks>
  ///  For internal use only. It's only in the interface section to prevent "Method of parameterized type declared in interface section must not use local symbol" error.
  /// </remarks>
  TDaintyEnumerator<T: class> = class(TEnumerator<T>)
  private
    FMapper: TDaintyMapper<T>;
    FDataSet: TDataSet;
    FCurrent: T;
  protected
    function DoGetCurrent: T; override;
    function DoMoveNext: Boolean; override;
  public
    constructor Create(AMapper: TDaintyMapper<T>; ADataSet: TDataSet);
  end;


  TDaintyValueSetter = reference to procedure(AInstance: TObject; AField: TField);


  TDaintyRttiFieldNameMapping = record
    FieldName: string;
    ValueSetter: TDaintyValueSetter;

    constructor Create(const AFieldName: string; const AValueSetter: TDaintyValueSetter);
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
    ValueSetter: TDaintyValueSetter;

    constructor Create(const AField: TField; const AValueSetter: TDaintyValueSetter);
  end;


  TDaintyRttiMapper<T: class> = class(TDaintyMapper<T>)
  private
    FConstruct: TFunc<TObject>;
    FFieldMapping: TList<TDaintyRttiFieldMapping>;
  public
    constructor Create(AClassMapping: TDaintyRttiClassMapping; ADataSet: TDataSet);

    function MapRow: T; override;
  end;


  TDaintyRttiMember = class
  private
    FRttiMember: TRttiMember;
  protected
    function GetRttiType: TRttiType; virtual; abstract;
  public
    constructor Create(ARttiMember: TRttiMember);

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

    procedure SetValue(AInstance: TObject; const AValue: TValue); override;
  end;

  TDaintyRttiPropertyMember = class(TDaintyRttiMember)
  private
    FProperty: TRttiProperty;
  protected
    function GetRttiType: TRttiType; override;
  public
    constructor Create(AProperty: TRttiProperty);

    procedure SetValue(AInstance: TObject; const AValue: TValue); override;
  end;


  TDaintyAbstractValueSetterFactoryClass = class of TDaintyAbstractValueSetterFactory;

  TDaintyAbstractValueSetterFactory = class
  public
    class function Construct(AMember: TDaintyRttiMember): TDaintyValueSetter; virtual; abstract;
  end;


  TDaintyRttiMapperFactory = class
  private type
    TValueSetterRegistration = record
      Factory: TDaintyAbstractValueSetterFactoryClass;
      Priority: Integer;

      constructor Create(AFactory: TDaintyAbstractValueSetterFactoryClass; APriority: Integer);
    end;
  private class var
    SContext: TRttiContext;
    SClassMappingCacheLock: TMultiReadExclusiveWriteSynchronizer;
    SClassMappingCache: TDictionary<Pointer, TDaintyRttiClassMapping>;
    SValueSettersLock: TMultiReadExclusiveWriteSynchronizer;
    SValueSetters: TList<TValueSetterRegistration>;
    SMembers: TObjectList<TDaintyRttiMember>;
  private
    class function GetClassMapping<T: class>: TDaintyRttiClassMapping;
    class function GetFieldName(AMember: TRttiNamedObject): string;
    class function GetValueSetter(AMember: TRttiMember): TDaintyValueSetter;
  protected
    class procedure Initialize;
    class procedure Finalize;
  public
    class function Construct<T: class>(ADataSet: TDataSet): TDaintyRttiMapper<T>;

    class procedure RegisterValueSetterFactory(AFactory: TDaintyAbstractValueSetterFactoryClass; APriority: Integer = 0);
    class procedure UnregisterValueSetterFactory(AFactory: TDaintyAbstractValueSetterFactoryClass);
  end;



implementation
uses
  System.TypInfo;


{ TDaintyDataSetHelper }
function TDaintyDataSetHelper.Rows<T>: TEnumerable<T>;
begin
  Result := TDainty.Rows<T>(Self);
end;


function TDaintyDataSetHelper.GetMapper<T>: TDaintyMapper<T>;
begin
  Result := TDainty.GetMapper<T>(Self);
end;


function TDaintyDataSetHelper.GetFirst<T>: T;
begin
  Result := TDainty.GetFirst<T>(Self);
end;


function TDaintyDataSetHelper.GetFirstOrDefault<T>(const ADefault: T): T;
begin
  Result := TDainty.GetFirstOrDefault<T>(Self, ADefault);
end;


function TDaintyDataSetHelper.GetSingle<T>: T;
begin
  Result := TDainty.GetSingle<T>(Self);
end;


function TDaintyDataSetHelper.GetSingleOrDefault<T>(const ADefault: T): T;
begin
  Result := TDainty.GetSingleOrDefault<T>(Self, ADefault);
end;


{ TDainty }
class function TDainty.Rows<T>(ADataSet: TDataSet): TEnumerable<T>;
var
  mapper: TDaintyMapper<T>;

begin
  mapper := GetMapper<T>(ADataSet);
  Result := TDaintyEnumerable<T>.Create(mapper, ADataSet);
end;


class function TDainty.GetMapper<T>(ADataSet: TDataSet): TDaintyMapper<T>;
begin
  Result := TDaintyRttiMapperFactory.Construct<T>(ADataSet);
end;


class function TDainty.GetFirst<T>(ADataSet: TDataSet): T;
var
  enumerator: TEnumerator<T>;

begin
  enumerator := Rows<T>(ADataSet).GetEnumerator;
  try
    if not enumerator.MoveNext then
      raise EDatabaseError.Create('Expected at least 1 record but none found');

    Result := enumerator.Current;
  finally
    FreeAndNil(enumerator);
  end;
end;


class function TDainty.GetFirstOrDefault<T>(ADataSet: TDataSet; const ADefault: T): T;
var
  enumerator: TEnumerator<T>;

begin
  enumerator := Rows<T>(ADataSet).GetEnumerator;
  try
    if enumerator.MoveNext then
      Result := enumerator.Current
    else
      Result := ADefault;
  finally
    FreeAndNil(enumerator);
  end;
end;


class function TDainty.GetSingle<T>(ADataSet: TDataSet): T;
var
  enumerator: TEnumerator<T>;

begin
  enumerator := Rows<T>(ADataSet).GetEnumerator;
  try
    if not enumerator.MoveNext then
      raise EDatabaseError.Create('Expected 1 record but none found');

    Result := enumerator.Current;

    if enumerator.MoveNext then
      raise EDatabaseError.Create('Expected 1 record but more found');
  finally
    FreeAndNil(enumerator);
  end;
end;


class function TDainty.GetSingleOrDefault<T>(ADataSet: TDataSet; const ADefault: T): T;
var
  enumerator: TEnumerator<T>;

begin
  enumerator := Rows<T>(ADataSet).GetEnumerator;
  try
    if not enumerator.MoveNext then
      Exit(ADefault);

    Result := enumerator.Current;

    if enumerator.MoveNext then
      Exit(ADefault);
  finally
    FreeAndNil(enumerator);
  end;
end;


{ TDaintyEnumerable<T> }
constructor TDaintyEnumerable<T>.Create(AMapper: TDaintyMapper<T>; ADataSet: TDataSet);
begin
  inherited Create;

  FMapper := AMapper;
  FDataSet := ADataSet;
end;


function TDaintyEnumerable<T>.DoGetEnumerator: TEnumerator<T>;
begin
  Result := TDaintyEnumerator<T>.Create(FMapper, FDataSet);
end;


{ TDaintyEnumerator<T> }
constructor TDaintyEnumerator<T>.Create(AMapper: TDaintyMapper<T>; ADataSet: TDataSet);
begin
  inherited Create;

  FMapper := AMapper;
  FDataSet := ADataSet;
end;


function TDaintyEnumerator<T>.DoGetCurrent: T;
begin
  Result := FCurrent;
end;


function TDaintyEnumerator<T>.DoMoveNext: Boolean;
begin
  if FDataSet.Eof then
    Exit(False);

  FCurrent := FMapper.MapRow;
  Result := True;

  FDataSet.Next;
end;


{ TDaintyRttiMapper<T> }
constructor TDaintyRttiMapper<T>.Create(AClassMapping: TDaintyRttiClassMapping; ADataSet: TDataSet);
var
  fieldNameMapping: TDaintyRttiFieldNameMapping;

begin
  inherited Create;

  FConstruct := AClassMapping.Construct;
  FFieldMapping := TList<TDaintyRttiFieldMapping>.Create;

  for fieldNameMapping in AClassMapping.FieldNameMapping do
    FFieldMapping.Add(TDaintyRttiFieldMapping.Create(ADataSet.FieldByName(fieldNameMapping.FieldName), fieldNameMapping.ValueSetter));
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
  SValueSettersLock := TMultiReadExclusiveWriteSynchronizer.Create;
  SValueSetters := TList<TValueSetterRegistration>.Create;
  SMembers := TObjectList<TDaintyRttiMember>.Create;
end;


class procedure TDaintyRttiMapperFactory.RegisterValueSetterFactory(AFactory: TDaintyAbstractValueSetterFactoryClass; APriority: Integer);
var
  registration: TValueSetterRegistration;
  registrationIndex: Integer;

begin
  { Initialization for Dainty.ValueSetter.Default runs before ours, make sure we are initialized }
  Initialize;

  SValueSettersLock.BeginWrite;
  try
    registration := TValueSetterRegistration.Create(AFactory, APriority);

    for registrationIndex := 0 to Pred(SValueSetters.Count) do
      if SValueSetters[registrationIndex].Priority <= APriority then
      begin
        SValueSetters.Insert(registrationIndex, registration);
        Exit;
      end;

    SValueSetters.Add(registration);
  finally
    SValueSettersLock.EndWrite;
  end;
end;


class procedure TDaintyRttiMapperFactory.UnregisterValueSetterFactory(AFactory: TDaintyAbstractValueSetterFactoryClass);
var
  registrationIndex: Integer;

begin
  SValueSettersLock.BeginWrite;
  try
    for registrationIndex := Pred(SValueSetters.Count) downto 0 do
      if SValueSetters[registrationIndex].Factory = AFactory then
        SValueSetters.Delete(registrationIndex);
  finally
    SValueSettersLock.EndWrite;
  end;
end;


class procedure TDaintyRttiMapperFactory.Finalize;
begin
  FreeAndNil(SValueSetters);
  FreeAndNil(SValueSettersLock);
  FreeAndNil(SClassMappingCache);
  FreeAndNil(SClassMappingCacheLock);
  SContext.Free;
end;


class function TDaintyRttiMapperFactory.Construct<T>(ADataSet: TDataSet): TDaintyRttiMapper<T>;
var
  mapping: TDaintyRttiClassMapping;

begin
  mapping := GetClassMapping<T>;
  Result := TDaintyRttiMapper<T>.Create(mapping, ADataSet);
end;


class function TDaintyRttiMapperFactory.GetClassMapping<T>: TDaintyRttiClassMapping;
var
  typeInfoHandle: Pointer;
  classInfo: TRttiType;
  method: TRttiMethod;
  instanceClassType: TClass;
  fieldInfo: TRttiField;
  propertyInfo: TRttiProperty;
  valueSetter: TProc<TObject, TField>;

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

        Result.FieldNameMapping.Add(TDaintyRttiFieldNameMapping.Create(GetFieldName(fieldInfo), GetValueSetter(fieldInfo)));
      end;


      for propertyInfo in classInfo.GetProperties do
      begin
        if not (propertyInfo.Visibility in [mvPublic, mvPublished]) then
          Continue;

        if not propertyInfo.IsWritable then
          Continue;

        Result.FieldNameMapping.Add(TDaintyRttiFieldNameMapping.Create(GetFieldName(propertyInfo), GetValueSetter(propertyInfo)));
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


class function TDaintyRttiMapperFactory.GetValueSetter(AMember: TRttiMember): TDaintyValueSetter;
var
  member: TDaintyRttiMember;
  registration: TValueSetterRegistration;

begin
  if AMember is TRttiField then
    member := TDaintyRttiFieldMember.Create(TRttiField(AMember))
  else if AMember is TRttiProperty then
    member := TDaintyRttiPropertyMember.Create(TRttiProperty(AMember))
  else
    raise EInvalidOpException.CreateFmt('Member type not supported: %s', [AMember.ClassName]);

  SValueSettersLock.BeginRead;
  try
    for registration in SValueSetters do
    begin
      Result := registration.Factory.Construct(member);
      if Assigned(Result) then
      begin
        SMembers.Add(member);
        Break;
      end;
    end;
  finally
    SValueSettersLock.EndRead;
  end;

  if not Assigned(Result) then
  begin
    FreeAndNil(member);
    raise ENotSupportedException.CreateFmt('Member %s has unsupported type for Dainty: %d', [AMember.Name, Ord(member.RttiType.TypeKind)]);
  end;
end;


{ TDaintyRttiMapperFactory.TValueSetterRegistration }
constructor TDaintyRttiMapperFactory.TValueSetterRegistration.Create(AFactory: TDaintyAbstractValueSetterFactoryClass; APriority: Integer);
begin
  Factory := AFactory;
  Priority := APriority;
end;


{ TDaintyRttiMapper<T> }
function TDaintyRttiMapper<T>.MapRow: T;
var
  fieldMapping: TDaintyRttiFieldMapping;

begin
  Result := FConstruct() as T;

  for fieldMapping in FFieldMapping do
    fieldMapping.ValueSetter(Result, fieldMapping.Field);
end;


{ TDaintyRttiFieldNameMapping }
constructor TDaintyRttiFieldNameMapping.Create(const AFieldName: string; const AValueSetter: TDaintyValueSetter);
begin
  FieldName := AFieldName;
  ValueSetter := AValueSetter;
end;


{ TDaintyRttiFieldMapping }
constructor TDaintyRttiFieldMapping.Create(const AField: TField; const AValueSetter: TDaintyValueSetter);
begin
  Field := AField;
  ValueSetter := AValueSetter;
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
