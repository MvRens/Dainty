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
unit Dainty.ValueSetter.Default;

interface
implementation
uses
  Data.DB,
  System.Rtti,
  System.TypInfo,

  Dainty;


type
  TDaintyDefaultValueSetterFactory = class(TDaintyAbstractValueSetterFactory)
  public
    class function Construct(AMember: TDaintyRttiMember): TDaintyValueSetter; override;
  end;


{ TDaintyDefaultValueSetterFactory }
class function TDaintyDefaultValueSetterFactory.Construct(AMember: TDaintyRttiMember): TDaintyValueSetter;
begin
  Result := nil;

  case AMember.RttiType.TypeKind of
    tkString,
    tkLString,
    tkWString,
    tkUString,
    tkChar,
    tkWChar:
      Result :=
        procedure(AInstance: TObject; AField: TField)
        begin
          AMember.SetValue(AInstance, AField.AsString);
        end;

    tkInteger:
      Result :=
        procedure(AInstance: TObject; AField: TField)
        begin
          AMember.SetValue(AInstance, AField.AsInteger);
        end;

    tkEnumeration:
      if AMember.RttiType.Handle = TypeInfo(Boolean) then
        Result :=
          procedure(AInstance: TObject; AField: TField)
          begin
            AMember.SetValue(AInstance, AField.AsBoolean);
          end
      else
        Result :=
          procedure(AInstance: TObject; AField: TField)
          begin
            AMember.SetValue(AInstance, AField.AsInteger);
          end;

    tkInt64:
      Result :=
        procedure(AInstance: TObject; AField: TField)
        begin
          AMember.SetValue(AInstance, AField.AsLargeInt);
        end;

    tkFloat:
      Result :=
        procedure(AInstance: TObject; AField: TField)
        begin
          AMember.SetValue(AInstance, AField.AsFloat);
        end;

    tkVariant:
      Result :=
        procedure(AInstance: TObject; AField: TField)
        begin
          AMember.SetValue(AInstance, TValue.FromVariant(AField.Value));
        end;
  end;
end;

initialization
  TDaintyRttiMapperFactory.RegisterValueSetterFactory(TDaintyDefaultValueSetterFactory);

end.
