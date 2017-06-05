%ignore FileGDBAPI::Row::GetFieldInformation;
%ignore FileGDBAPI::Row::IsNull;
%ignore FileGDBAPI::Row::SetNull;
%ignore FileGDBAPI::Row::GetDate;
%ignore FileGDBAPI::Row::SetDate;
%ignore FileGDBAPI::Row::GetDouble;
%ignore FileGDBAPI::Row::SetDouble;
%ignore FileGDBAPI::Row::GetFloat;
%ignore FileGDBAPI::Row::SetFloat;
%ignore FileGDBAPI::Row::GetBinary;
%ignore FileGDBAPI::Row::SetBinary;
%ignore FileGDBAPI::Row::GetGeometry;
%ignore FileGDBAPI::Row::SetGeometry;
%ignore FileGDBAPI::Row::GetGUID;
%ignore FileGDBAPI::Row::SetGUID;
%ignore FileGDBAPI::Row::GetGlobalID;
%ignore FileGDBAPI::Row::SetGlobalID;
%ignore FileGDBAPI::Row::GetInteger;
%ignore FileGDBAPI::Row::SetInteger;
%ignore FileGDBAPI::Row::GetOID;
%ignore FileGDBAPI::Row::SetOID;
%ignore FileGDBAPI::Row::GetRaster;
%ignore FileGDBAPI::Row::SetRaster;
%ignore FileGDBAPI::Row::GetShort;
%ignore FileGDBAPI::Row::SetShort;
%ignore FileGDBAPI::Row::GetString;
%ignore FileGDBAPI::Row::SetString;
%ignore FileGDBAPI::Row::GetXML;
%ignore FileGDBAPI::Row::SetXML;
%ignore FileGDBAPI::Row::GetFields;
%ignore FileGDBAPI::Row::getFields;

%include "Row.h"

%extend FileGDBAPI::Row {
  bool isNull(std::wstring name) {
    bool value;
    checkResult(self->IsNull(name,value));
    return value;
  }
  void setNull(std::wstring name) {
    checkResult(self->SetNull(name));
  }
 
  long long getDate(const std::wstring& name) {
    struct tm value;
    checkResult(self->GetDate(name,value));
    return mktime(&value);
  }
  void setDate(const std::wstring& name, long long date) {
    const time_t time = (time_t)date;
    struct tm* tm_time = localtime(&time);
    if (tm_time == 0) {
      std::stringstream message;
      message << "Invalid date ";
      message << date;
      throw std::runtime_error(message.str());
    } else {
      struct tm value;
      value = *tm_time;
      checkResult(self->SetDate(name, value));
    }
  }

  double getDouble(const std::wstring& name) {
    double value;
    checkResult(self->GetDouble(name,value));
    return value;
  }
  
  void setDouble(const std::wstring& name, double value) {
    checkResult(self->SetDouble(name, value));
  }
 
  float getFloat(const std::wstring& name) {
    float value;
    checkResult(self->GetFloat(name,value));
    return value;
  }
  
  void setFloat(const std::wstring& name, double value) {
    checkResult(self->SetFloat(name, value));
  }

  FileGDBAPI::Guid getGuid(std::wstring name) {
    FileGDBAPI::Guid value;
    checkResult(self->GetGUID(name,value));
    return value;
  }
 
  FileGDBAPI::Guid getGlobalId() {
    FileGDBAPI::Guid value;
    checkResult(self->GetGlobalID(value));
    return value;
  }
  
  void setGuid(const std::wstring& name, const FileGDBAPI::Guid& value) {
    checkResult(self->SetGUID(name, value));
  }

  int getOid() {
    int value;
    checkResult(self->GetOID(value));
    return value;
  }

  short getShort(const std::wstring& name) {
    short value;
    checkResult(self->GetShort(name,value));
    return value;
  }
  
  void setShort(const std::wstring& name, short value) {
    checkResult(self->SetShort(name, value));
  }

  int32 getInteger(const std::wstring& name) {
    int value;
    checkResult(self->GetInteger(name,value));
    return value;
  }
    
  void setInteger(const std::wstring& name, int32 value) {
    checkResult(self->SetInteger(name, value));
  }
  
  std::wstring getString(const std::wstring& name) {
    std::wstring value;
    checkResult(self->GetString(name,value));
    return value;
  }
  
  void setString(const std::wstring& name, const std::wstring& value) {
    checkResult(self->SetString(name, value));
  }

  std::string getXML(const std::wstring& name) {
    std::string value;
    checkResult(self->GetXML(name,value));
    return value;
  }
  
  void setXML(const std::wstring& name, const std::string& value) {
    checkResult(self->SetXML(name, value));
  }

  byte_array getGeometry() {
    FileGDBAPI::ShapeBuffer geometry;
    checkResult(self->GetGeometry(geometry));
    
    byte_array buffer;
    buffer.bytes = new byte[geometry.inUseLength];
    memcpy(buffer.bytes, geometry.shapeBuffer, geometry.inUseLength);
    buffer.length = geometry.inUseLength;
    
    return buffer;
  }
   
  void setGeometry(char* byteArray, size_t length) {
    FileGDBAPI::ShapeBuffer shape;
    shape.Allocate(length);
    for (size_t i = 0; i < length; i++) {
      char c = byteArray[i];
      shape.shapeBuffer[i] = (byte)c;
    }
    shape.inUseLength = length;
    checkResult(self->SetGeometry(shape));
  }
   
  std::vector<FileGDBAPI::FieldDef> getFields {
    std::vector<FileGDBAPI::FieldDef> value;
    checkResult(self->GetFields(value));
    return value;
  }
}

%typemap(javainterfaces) FileGDBAPI::Row "java.io.Closeable"

%typemap(javacode) FileGDBAPI::Row %{
  public void close() {
    delete();
  }
%}
