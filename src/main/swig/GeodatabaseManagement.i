%ignore FileGDBAPI::CreateGeodatabase;
%ignore FileGDBAPI::OpenGeodatabase;

%newobject createGeodatabase;
%newobject openGeodatabase;
%inline {
  FileGDBAPI::Geodatabase* createGeodatabase(const std::wstring& path) {
    FileGDBAPI::Geodatabase* value = new FileGDBAPI::Geodatabase();
    checkResult(FileGDBAPI::CreateGeodatabase(path, *value));
    return value;
  }
  FileGDBAPI::Geodatabase* openGeodatabase(const std::wstring& path) {
    FileGDBAPI::Geodatabase* value = new FileGDBAPI::Geodatabase();
    checkResult(FileGDBAPI::OpenGeodatabase(path, *value));
    return value;
  }
}

%include "GeodatabaseManagement.h"

%rename(createGeodatabase2) FileGDBAPI::CreateGeodatabase;
%rename(openGeodatabase2) FileGDBAPI::OpenGeodatabase;
%rename(closeGeodatabase2) FileGDBAPI::CloseGeodatabase;
%rename(deleteGeodatabase2) FileGDBAPI::DeleteGeodatabase;
