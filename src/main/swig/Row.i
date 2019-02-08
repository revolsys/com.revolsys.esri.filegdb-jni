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

%typemap(javainterfaces) FileGDBAPI::Row "java.io.Closeable"

%typemap(javacode) FileGDBAPI::Row %{
  public void close() {
    delete();
  }
%}

%include "Row.h"

%extend FileGDBAPI::Row {
 
  FileGDBAPI::Guid getGlobalId() {
    FileGDBAPI::Guid value;
    checkResult(self->GetGlobalID(value));
    return value;
  }

  int getOid() {
    int value;
    checkResult(self->GetOID(value));
    return value;
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
  bool isNull(const int fieldNumber) {
    bool value;
    checkResult(self->IsNull(fieldNumber,value));
    return value;
  }
  void setNull(const int fieldNumber) {
    checkResult(self->SetNull(fieldNumber));
  }
 
  long long getDate(const int fieldNumber) {
    struct tm value;
    checkResult(self->GetDate(fieldNumber,value));
    return mktime(&value);
  }
  void setDate(const int fieldNumber, long long date) {
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
      checkResult(self->SetDate(fieldNumber, value));
    }
  }

  double getDouble(const int fieldNumber) {
    double value;
    checkResult(self->GetDouble(fieldNumber,value));
    return value;
  }
  
  void setDouble(const int fieldNumber, double value) {
    checkResult(self->SetDouble(fieldNumber, value));
  }
 
  float getFloat(const int fieldNumber) {
    float value;
    checkResult(self->GetFloat(fieldNumber,value));
    return value;
  }
  
  void setFloat(const int fieldNumber, double value) {
    checkResult(self->SetFloat(fieldNumber, value));
  }

  FileGDBAPI::Guid getGuid(const int fieldNumber) {
    FileGDBAPI::Guid value;
    checkResult(self->GetGUID(fieldNumber,value));
    return value;
  }
  
  void setGuid(const int fieldNumber, const FileGDBAPI::Guid& value) {
    checkResult(self->SetGUID(fieldNumber, value));
  }

  short getShort(const int fieldNumber) {
    short value;
    checkResult(self->GetShort(fieldNumber,value));
    return value;
  }
  
  void setShort(const int fieldNumber, short value) {
    checkResult(self->SetShort(fieldNumber, value));
  }

  int32 getInteger(const int fieldNumber) {
    int value;
    checkResult(self->GetInteger(fieldNumber,value));
    return value;
  }
    
  void setInteger(const int fieldNumber, int32 value) {
    checkResult(self->SetInteger(fieldNumber, value));
  }
  
  std::wstring getString(const int fieldNumber) {
    std::wstring value;
    checkResult(self->GetString(fieldNumber,value));
    return value;
  }
  
  void setString(const int fieldNumber, const std::wstring& value) {
    checkResult(self->SetString(fieldNumber, value));
  }

  std::string getXML(const int fieldNumber) {
    std::string value;
    checkResult(self->GetXML(fieldNumber,value));
    return value;
  }
  
  void setXML(const int fieldNumber, const std::string& value) {
    checkResult(self->SetXML(fieldNumber, value));
  }
}
