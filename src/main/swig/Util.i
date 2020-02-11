%ignore FileGDBAPI::BezierCurve;
%ignore FileGDBAPI::Curve;
%ignore FileGDBAPI::CircularArcCurve;
%ignore FileGDBAPI::EllipticArcCurve;

%ignore FileGDBAPI::ErrorInfo::GetErrorRecordCount;
%ignore FileGDBAPI::ErrorInfo::GetErrorDescription;
%ignore FileGDBAPI::ErrorInfo::GetErrorRecord;
%ignore FileGDBAPI::ErrorInfo::ClearErrors;

%ignore FileGDBAPI::FieldDef::GetGeometryDef;
%ignore FileGDBAPI::FieldDef::SetGeometryDef;
%ignore FileGDBAPI::FieldDef::GetAlias;
%ignore FileGDBAPI::FieldDef::GetName;
%ignore FileGDBAPI::FieldDef::GetLength;
%ignore FileGDBAPI::FieldDef::GetIsNullable;
%ignore FileGDBAPI::FieldDef::GetType;

%ignore FileGDBAPI::FieldInfo::GetFieldCount;
%ignore FileGDBAPI::FieldInfo::GetFieldName;
%ignore FileGDBAPI::FieldInfo::GetFieldLength;
%ignore FileGDBAPI::FieldInfo::GetFieldType;
%ignore FileGDBAPI::FieldInfo::GetFieldIsNullable;

%ignore FileGDBAPI::GeometryDef;
%ignore FileGDBAPI::GeometryDef::GetGeometryType;
%ignore FileGDBAPI::GeometryDef::GetHasM;
%ignore FileGDBAPI::GeometryDef::GetHasZ;

%rename(equal) FileGDBAPI::Guid::operator==;
%rename(notEqual) FileGDBAPI::Guid::operator!=;
%ignore FileGDBAPI::Guid::ToString;
%ignore FileGDBAPI::Guid::data1;
%ignore FileGDBAPI::Guid::data2;
%ignore FileGDBAPI::Guid::data3;
%ignore FileGDBAPI::Guid::data4;

%ignore FileGDBAPI::IndexDef::GetIsUnique;
%ignore FileGDBAPI::IndexDef::GetName;
%ignore FileGDBAPI::IndexDef::GetFields;

%ignore FileGDBAPI::SpatialReference;

%ignore FileGDBAPI::ShapeBuffer;
%ignore FileGDBAPI::ByteArray;

%ignore FileGDBAPI::EnumSpatialReferenceInfo;
%ignore FileGDBAPI::SpatialReferenceInfo;
%ignore FileGDBAPI::SpatialReferences::FindSpatialReferenceByName;
%ignore FileGDBAPI::SpatialReferences::FindSpatialReferenceBySRID;

%ignore FileGDBAPI::Point;
%ignore FileGDBAPI::PointShapeBuffer;
%ignore FileGDBAPI::MultiPointShapeBuffer;
%ignore FileGDBAPI::MultiPartShapeBuffer;
%ignore FileGDBAPI::MultiPatchShapeBuffer;

%ignore FileGDBAPI::EnumRows::getFields;
%ignore FileGDBAPI::EnumRows::GetFieldInformation;
%ignore FileGDBAPI::EnumRows::Next;
%ignore FileGDBAPI::EnumRows::GetFields;

%include "Util.h"

// FieldDef

%extend FileGDBAPI::FieldDef {
  std::wstring getAlias() {
    std::wstring value;
    checkResult(self->GetAlias(value));
    return value;
  }
  std::wstring getName() {
    std::wstring value;
    checkResult(self->GetName(value));
    return value;
  }
  bool isNullable() {
    bool result;
    checkResult(self->GetIsNullable(result));
    return result;
  }
  int getLength() {
    int result;
    checkResult(self->GetLength(result));
    return result;
  }
  FileGDBAPI::FieldType getType() {
    FileGDBAPI::FieldType result;
    checkResult(self->GetType(result));
    return result;
  }
}

// FieldInfo

%extend FileGDBAPI::FieldInfo {
  int getFieldCount() {
    int count;
    checkResult(self->GetFieldCount(count));
    return count;
  }

  std::wstring getFieldName(int i) {
    std::wstring name;
    checkResult(self->GetFieldName(i, name));
    return name;
  }

  int getFieldLength(int i) {
    int length;
    checkResult(self->GetFieldLength(i, length));
    return length;
  }
  bool isNullable(int i) {
    bool nullable;
    checkResult(self->GetFieldIsNullable(i, nullable));
    return nullable;
  }

  FileGDBAPI::FieldType getFieldType(int i) {
    FileGDBAPI::FieldType type;
    checkResult(self->GetFieldType(i, type));
    return type;
  }
}

// GeometryDef

%extend FileGDBAPI::GeometryDef {
  bool hasM() {
    bool result;
    checkResult(self->GetHasM(result));
    return result;
  }
  bool hasZ() {
    bool result;
    checkResult(self->GetHasZ(result));
    return result;
  }
  FileGDBAPI::GeometryType getGeometryType() {
    FileGDBAPI::GeometryType result;
    checkResult(self->GetGeometryType(result));
    return result;
  }
}

// IndexDef

%extend FileGDBAPI::IndexDef {
  bool isUnique() {
    bool result;
    checkResult(self->GetIsUnique(result));
    return result;
  }
  std::wstring getName() {
    std::wstring result;
    checkResult(self->GetName(result));
    return result;
  }
  std::wstring getFields {
    std::wstring result;
    checkResult(self->GetFields(result));
    return result;
  }
}

// Guid

%extend FileGDBAPI::Guid {
  std::wstring toString() {
    std::wstring value;
    checkResult(self->ToString(value));
    return value;
  }
}

// EnumRows

%newobject FileGDBAPI::EnumRows::next;

%extend FileGDBAPI::EnumRows {
  FileGDBAPI::Row* next() {
    FileGDBAPI::Row* value = new FileGDBAPI::Row();
    int hr = self->Next(*value);
    if (hr == S_OK) {
      return value;
    } else {
      delete value;
      return NULL;
    }
  }

  std::vector<FileGDBAPI::FieldDef> getFields {
    std::vector<FileGDBAPI::FieldDef> value;
    checkResult(self->GetFields(value));
    return value;
  }
}

%typemap(javafinalize) FileGDBAPI::EnumRows %{
   protected void finalize() {
   }
%}