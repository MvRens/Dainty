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
unit Dainty.Converter.Default;

interface
implementation
uses
  Data.DB,
  System.Rtti,
  System.TypInfo,

  Dainty;


type
  TDaintyDefaultConverterFactory = class(TDaintyRttiConverterFactory)
  public
    class function Construct(AMember: TDaintyRttiMember; out AConverter: TDaintyConverter): Boolean; override;
  end;


{ TDaintyDefaultConverterFactory }
class function TDaintyDefaultConverterFactory.Construct(AMember:  TDaintyRttiMember; out AConverter: TDaintyConverter): Boolean;
begin
  Result := True;

  case AMember.RttiType.TypeKind of
    tkString,
    tkLString,
    tkWString,
    tkUString,
    tkChar,
    tkWChar:
      begin
        AConverter.FieldReader :=
          procedure(AInstance: TObject; AField: TField)
          begin
            AMember.SetValue(AInstance, AField.AsString);
          end;

        AConverter.ParamWriter :=
          procedure(AInstance: TObject; AParam: TParam)
          begin
            AParam.AsString := AMember.GetValue(AInstance).AsString;
          end;
      end;

    tkInteger:
      begin
        AConverter.FieldReader :=
          procedure(AInstance: TObject; AField: TField)
          begin
            AMember.SetValue(AInstance, AField.AsInteger);
          end;

        AConverter.ParamWriter :=
          procedure(AInstance: TObject; AParam: TParam)
          begin
            AParam.AsInteger := AMember.GetValue(AInstance).AsInteger;
          end;
      end;

    tkEnumeration:
      if AMember.RttiType.Handle = TypeInfo(Boolean) then
      begin
        AConverter.FieldReader :=
          procedure(AInstance: TObject; AField: TField)
          begin
            AMember.SetValue(AInstance, AField.AsBoolean);
          end;

        AConverter.ParamWriter :=
          procedure(AInstance: TObject; AParam: TParam)
          begin
            AParam.AsBoolean := AMember.GetValue(AInstance).AsBoolean;
          end;
      end else
      begin
        AConverter.FieldReader :=
          procedure(AInstance: TObject; AField: TField)
          begin
            AMember.SetValue(AInstance, AField.AsInteger);
          end;

        AConverter.ParamWriter :=
          procedure(AInstance: TObject; AParam: TParam)
          begin
            AParam.AsInteger := AMember.GetValue(AInstance).AsInteger;
          end;
      end;

    tkInt64:
      begin
        AConverter.FieldReader :=
          procedure(AInstance: TObject; AField: TField)
          begin
            AMember.SetValue(AInstance, AField.AsLargeInt);
          end;

        AConverter.ParamWriter :=
          procedure(AInstance: TObject; AParam: TParam)
          begin
            AParam.AsLargeInt := AMember.GetValue(AInstance).AsInt64;
          end;
      end;

    tkFloat:
      begin
        AConverter.FieldReader :=
          procedure(AInstance: TObject; AField: TField)
          begin
            AMember.SetValue(AInstance, AField.AsFloat);
          end;

        AConverter.ParamWriter :=
          procedure(AInstance: TObject; AParam: TParam)
          begin
            AParam.AsFloat := AMember.GetValue(AInstance).AsExtended;
          end;
      end;

    tkVariant:
      begin
        AConverter.FieldReader :=
          procedure(AInstance: TObject; AField: TField)
          begin
            AMember.SetValue(AInstance, TValue.FromVariant(AField.Value));
          end;

        AConverter.ParamWriter :=
          procedure(AInstance: TObject; AParam: TParam)
          begin
            AParam.Value := AMember.GetValue(AInstance).AsVariant;
          end;
      end
  else
    Result := False;
  end;
end;


initialization
  TDaintyRttiMapperFactory.RegisterConverterFactory(TDaintyDefaultConverterFactory);

end.
