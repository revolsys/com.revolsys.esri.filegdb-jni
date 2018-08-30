%module "EsriFileGdb"

%define __linux__
%enddef

%{

#include <stdexcept>
#include <sstream>
#include <iostream>
#include <stdio.h>
#include "time.h"
#include "FileGDBAPI.h"

std::string wstring2string(std::wstring wstr) {
  std::string str(wstr.length(),' ');
  copy(wstr.begin(),wstr.end(),str.begin());
  return str;
}

fgdbError checkResult(fgdbError error) {
  if (error) {
     std::wstring errorString;
     if (FileGDBAPI::ErrorInfo::GetErrorDescription(error, errorString) == S_FALSE) {
         throw std::runtime_error("Unknown error");
     } else {
       std::stringstream out;
       out << wstring2string(errorString) << " (" << error << ")";
       std::string message = out.str();
       throw std::runtime_error(message);
     }
  }
  return error;
}

void handleException(JNIEnv *jenv, const std::exception e) {
  std::stringstream message;
  message << e.what() ;
  jclass clazz = jenv->FindClass("com/revolsys/gis/esri/gdb/file/FileGdbException");
  jenv->ThrowNew(clazz, message.str().c_str());
}
  
void handleException(JNIEnv *jenv, const std::runtime_error e) {
  std::stringstream message;
  message << e.what() ;
  jclass clazz = jenv->FindClass("com/revolsys/gis/esri/gdb/file/FileGdbException");
  jenv->ThrowNew(clazz, message.str().c_str());
}

%}

%pragma(java) jniclassimports=%{
import java.io.IOException;

import org.scijava.nativelib.NativeLibraryUtil;
import org.scijava.nativelib.NativeLibraryUtil.Architecture;
import org.scijava.nativelib.NativeLoader;
%}

%pragma(java) jniclasscode=%{
  static {
    Architecture arch = NativeLibraryUtil.getArchitecture();
    try {
      if (arch == Architecture.LINUX_64 ||arch == Architecture.OSX_64) {
        NativeLoader.loadLibrary("fgdbunixrtl");
        NativeLoader.loadLibrary("FileGDBAPI");
        NativeLoader.loadLibrary("FileGdbJni");
      } else if (arch == Architecture.WINDOWS_64) {
        NativeLoader.loadLibrary("FileGDBAPI");
        NativeLoader.loadLibrary("Esri.FileGDBAPI");
        NativeLoader.loadLibrary("FileGdbJni");
        EsriFileGdb.setMaxOpenFiles(2048);
      } else {
        System.err.println("ESRI FGDB API not supported for Architecture: " + arch);
      }
    } catch (IOException e) {
      System.err.println("Error loading ESRI FGDB API for Architecture: " + arch);
      e.printStackTrace();
    }
  }
%}

%include "std_vector.i"
%include "std_string.i"
%include "std_wstring.i"
%include "typemaps.i"
%include "enums.swg"
%include "OutParam.i"
%include "OutArrayParam.i"
%javaconst(1);

%apply unsigned char *OUTPUT {byte *output};
%apply (char *STRING, size_t LENGTH)   { (char *byteArray, size_t length) };


%{
  struct byte_array {
    byte* bytes;
    size_t length;
  };
%}

%typemap(out) byte_array {
  jbyteArray buffer = JCALL1(NewByteArray, jenv, $1.length);
  jbyte* bytes = (jbyte*)$1.bytes;
  JCALL4(SetByteArrayRegion, jenv, buffer, 0, $1.length, bytes);
  delete $1.bytes;
  $result = buffer;
}
%typemap(jtype) byte_array "byte[]"
%typemap(jstype) byte_array "byte[]"
%typemap(jni) byte_array "jbyteArray"
%typemap(javaout) byte_array {
  return $jnicall;
}


%ignore byte_array;

%template(VectorOfString) std::vector<std::string>;
%template(VectorOfWString) std::vector<std::wstring>;

%include "Array.i"

%define linux
%enddef

%exception {
  try {
    $action;
  } catch (const std::runtime_error& e) {
    handleException(jenv, e);
  } catch (const std::exception& e) {
    handleException(jenv, e);
  }
}

%inline {
  void setMaxOpenFiles(int maxOpenFiles) {
#ifdef _WIN32
  _setmaxstdio(maxOpenFiles);
#else
  maxOpenFiles++;
#endif
  }
  
  std::vector<std::wstring> getErrors() {
    std::vector<std::wstring> errors;
    int errorCount;
    fgdbError hr;
    FileGDBAPI::ErrorInfo::GetErrorRecordCount(errorCount);
    for (int i = 0; i < errorCount; i++) {
      std::wstring errorText;
      FileGDBAPI::ErrorInfo::GetErrorRecord(i, hr, errorText);
      errors.push_back(errorText);
    }
    FileGDBAPI::ErrorInfo::ClearErrors();
    return errors;
  }
  
  std::wstring getSpatialReferenceWkt(int srid) {
    FileGDBAPI::SpatialReferenceInfo value;
    FileGDBAPI::SpatialReferences::FindSpatialReferenceBySRID(srid, value);
    return value.srtext;
  }
}

%include "FileGDBCore.i"

%include Util.i

%include "GeodatabaseManagement.i"

%include "Geodatabase.i"

%include "Table.i"

%include Row.i

%include "Raster.h"
