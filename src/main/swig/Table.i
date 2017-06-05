%typemap(javafinalize) FileGDBAPI::Table %{
   protected void finalize() {
   }
%}

%ignore FileGDBAPI::Table::AddField;
%ignore FileGDBAPI::Table::AddIndex;
%ignore FileGDBAPI::Table::GetFields;
%ignore FileGDBAPI::Table::GetFieldInformation;
%ignore FileGDBAPI::Table::IsEditable;
%ignore FileGDBAPI::Table::GetDefinition;
%ignore FileGDBAPI::Table::GetDocumentation;
%ignore FileGDBAPI::Table::GetRowCount;
%ignore FileGDBAPI::Table::GetDefaultSubtypeCode;
%ignore FileGDBAPI::Table::CreateRowObject;
%ignore FileGDBAPI::Table::GetIndexes;
%ignore FileGDBAPI::Table::getFields;
%ignore FileGDBAPI::Table::Search;
%ignore FileGDBAPI::Table::Insert;
%ignore FileGDBAPI::Table::Update;
%ignore FileGDBAPI::Table::Delete;
%ignore FileGDBAPI::Table::SetWriteLock;
%ignore FileGDBAPI::Table::FreeWriteLock;
%ignore FileGDBAPI::Table::LoadOnlyMode;
%ignore FileGDBAPI::Table::Delete;

%include "Table.h"

%newobject FileGDBAPI::Table::createRowObject;
%newobject FileGDBAPI::Table::search;
%extend FileGDBAPI::Table {
  bool isEditable() {
    bool value;
    checkResult(self->IsEditable(value));
    return value;
  }
  std::string getDefinition() {
    std::string value;
    checkResult(self->GetDefinition(value));
    return value;
  }
  std::string getDocumentation() {
    std::string value;
    checkResult(self->GetDocumentation(value));
    return value;
  }
  int getRowCount() {
    int value;
    checkResult(self->GetRowCount(value));
    return value;
  }
  int getDefaultSubtypeCode() {
    int value;
    checkResult(self->GetDefaultSubtypeCode(value));
    return value;
  }
  std::vector<std::string> getIndexes() {
    std::vector<std::string> value;
    checkResult(self->GetIndexes(value));
    return value;
  }
  FileGDBAPI::Row* createRowObject() {
    FileGDBAPI::Row* value = new FileGDBAPI::Row();
    checkResult(self->CreateRowObject(*value));
    return value;
  }
  void insertRow(FileGDBAPI::Row& row) {
    checkResult(self->Insert(row));
  }
  void updateRow(FileGDBAPI::Row& row) {
    checkResult(self->Update(row));
  }
  void deleteRow(FileGDBAPI::Row& row) {
    checkResult(self->Delete(row));
  }

  FileGDBAPI::EnumRows* search(const std::wstring& subfields, const std::wstring& whereClause, Envelope envelope, bool recycling) {
    FileGDBAPI::EnumRows* rows = new FileGDBAPI::EnumRows();
    checkResult(self->Search(subfields, whereClause, envelope, recycling, *rows));
    return rows;
  }

  FileGDBAPI::EnumRows* search(const std::wstring& subfields, const std::wstring& whereClause, bool recycling) {
    FileGDBAPI::EnumRows* rows = new FileGDBAPI::EnumRows();
    checkResult(self->Search(subfields, whereClause, recycling, *rows));
    return rows;
  }
  void setLoadOnlyMode(bool loadOnly) {
    checkResult(self->LoadOnlyMode(loadOnly));
  }
  void setWriteLock() {
    checkResult(self->SetWriteLock());
  }
  void freeWriteLock() {
    checkResult(self->FreeWriteLock());
  }

  std::vector<FileGDBAPI::FieldDef> getFields {
    std::vector<FileGDBAPI::FieldDef> value;
    checkResult(self->GetFields(value));
    return value;
  }
}
