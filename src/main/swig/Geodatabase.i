%ignore FileGDBAPI::Geodatabase::ExecuteSQL;
%ignore FileGDBAPI::Geodatabase::GetDatasetDefinition;
%ignore FileGDBAPI::Geodatabase::GetDatasetDocumentation;
%ignore FileGDBAPI::Geodatabase::GetQueryName;
%ignore FileGDBAPI::Geodatabase::OpenTable;
%ignore FileGDBAPI::Geodatabase::CloseTable;
%ignore FileGDBAPI::Geodatabase::CreateTable;
%ignore FileGDBAPI::Geodatabase::CreateDomain;
%ignore FileGDBAPI::Geodatabase::AlterDomain;
%ignore FileGDBAPI::Geodatabase::DeleteDomain;
%ignore FileGDBAPI::Geodatabase::GetDomainDefinition;
%ignore FileGDBAPI::Geodatabase::GetDomains;
%ignore FileGDBAPI::Geodatabase::GetChildDatasets;
%ignore FileGDBAPI::Geodatabase::CreateFeatureDataset;

%include "Geodatabase.h"

%newobject FileGDBAPI::Geodatabase::createTable;
%newobject FileGDBAPI::Geodatabase::openTable;

%extend FileGDBAPI::Geodatabase {
  void createFeatureDataset(std::string featureDatasetDef) {
    checkResult(self->CreateFeatureDataset(featureDatasetDef));
  }

  FileGDBAPI::EnumRows* query(const std::wstring& sql, bool recycling) {
    FileGDBAPI::EnumRows* rows = new FileGDBAPI::EnumRows();
    checkResult(self->ExecuteSQL(sql, recycling, *rows));
    return rows;
  }

  std::vector<std::wstring> getChildDatasets(std::wstring parentPath, std::wstring datasetType) {
    std::vector<std::wstring> value;
    checkResult(self->GetChildDatasets(parentPath, datasetType, value));
    return value;
  }
  
  std::string getDatasetDefinition(std::wstring path, std::wstring datasetType) {
    std::string value;
    checkResult(self->GetDatasetDefinition(path, datasetType, value));
    return value;
  }
  
  std::string getDatasetDocumentation(std::wstring path, std::wstring datasetType) {
    std::string value;
    checkResult(self->GetDatasetDocumentation(path, datasetType, value));
    return value;
  }
  
  std::vector<std::wstring> getDomains() {
    std::vector<std::wstring> value;
    checkResult(self->GetDomains(value));
    return value;
  }
  
  std::string getDomainDefinition(std::wstring domainName) {
    std::string value;
    checkResult(self->GetDomainDefinition(domainName, value));
    return value;
  }
  void createDomain(const std::string& domainDefinition) {
    checkResult(self->CreateDomain(domainDefinition));
  }
  void alterDomain(const std::string& domainDefinition) {
    checkResult(self->AlterDomain(domainDefinition));
  }
  void deleteDomain(const std::wstring& domainName) {
    checkResult(self->DeleteDomain(domainName));
  }
  
  std::wstring getQueryName(std::wstring path) {
    std::wstring value;
    checkResult(self->GetQueryName(path, value));
    return value;
  }
  FileGDBAPI::Table* openTable(const std::wstring& path) {
    FileGDBAPI::Table* value = new FileGDBAPI::Table();
    checkResult(self->OpenTable(path, *value));
    return value;
  }
  void closeTable(FileGDBAPI::Table& table) {
    checkResult(self->CloseTable(table));
  }
  std::string getTableDefinition(const std::wstring& path) {
    FileGDBAPI::Table table;
    checkResult(self->OpenTable(path, table));
    std::string tableDefinition;
    checkResult(table.GetDefinition(tableDefinition));
    checkResult(self->OpenTable(path, table));
    
    return tableDefinition;
  }
  FileGDBAPI::Table* createTable(const std::string& tableDefinition, const std::wstring& parent) {
    FileGDBAPI::Table* value = new FileGDBAPI::Table();
    checkResult(self->CreateTable(tableDefinition, parent, *value));
    return value;
  }
}

%typemap(javafinalize) FileGDBAPI::Geodatabase %{
   protected void finalize() {
   }
%}