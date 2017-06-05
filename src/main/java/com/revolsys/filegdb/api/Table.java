/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.12
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package com.revolsys.filegdb.api;

public class Table {
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  protected Table(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(Table obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

   protected void finalize() {
   }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        EsriFileGdbJNI.delete_Table(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public int SetDocumentation(String documentation) {
    return EsriFileGdbJNI.Table_SetDocumentation(swigCPtr, this, documentation);
  }

  public int AlterField(String fieldDef) {
    return EsriFileGdbJNI.Table_AlterField(swigCPtr, this, fieldDef);
  }

  public int DeleteField(String fieldName) {
    return EsriFileGdbJNI.Table_DeleteField(swigCPtr, this, fieldName);
  }

  public int DeleteIndex(String indexName) {
    return EsriFileGdbJNI.Table_DeleteIndex(swigCPtr, this, indexName);
  }

  public int CreateSubtype(String subtypeDef) {
    return EsriFileGdbJNI.Table_CreateSubtype(swigCPtr, this, subtypeDef);
  }

  public int AlterSubtype(String subtypeDef) {
    return EsriFileGdbJNI.Table_AlterSubtype(swigCPtr, this, subtypeDef);
  }

  public int DeleteSubtype(String subtypeName) {
    return EsriFileGdbJNI.Table_DeleteSubtype(swigCPtr, this, subtypeName);
  }

  public int EnableSubtypes(String subtypeFieldName, String subtypeDef) {
    return EsriFileGdbJNI.Table_EnableSubtypes(swigCPtr, this, subtypeFieldName, subtypeDef);
  }

  public int SetDefaultSubtypeCode(int defaultCode) {
    return EsriFileGdbJNI.Table_SetDefaultSubtypeCode(swigCPtr, this, defaultCode);
  }

  public int DisableSubtypes() {
    return EsriFileGdbJNI.Table_DisableSubtypes(swigCPtr, this);
  }

  public int GetExtent(Envelope extent) {
    return EsriFileGdbJNI.Table_GetExtent(swigCPtr, this, Envelope.getCPtr(extent), extent);
  }

  public Table() {
    this(EsriFileGdbJNI.new_Table(), true);
  }

  public boolean isEditable() {
    return EsriFileGdbJNI.Table_isEditable(swigCPtr, this);
  }

  public String getDefinition() {
    return EsriFileGdbJNI.Table_getDefinition(swigCPtr, this);
  }

  public String getDocumentation() {
    return EsriFileGdbJNI.Table_getDocumentation(swigCPtr, this);
  }

  public int getRowCount() {
    return EsriFileGdbJNI.Table_getRowCount(swigCPtr, this);
  }

  public int getDefaultSubtypeCode() {
    return EsriFileGdbJNI.Table_getDefaultSubtypeCode(swigCPtr, this);
  }

  public VectorOfString getIndexes() {
    return new VectorOfString(EsriFileGdbJNI.Table_getIndexes(swigCPtr, this), true);
  }

  public Row createRowObject() {
    long cPtr = EsriFileGdbJNI.Table_createRowObject(swigCPtr, this);
    return (cPtr == 0) ? null : new Row(cPtr, true);
  }

  public void insertRow(Row row) {
    EsriFileGdbJNI.Table_insertRow(swigCPtr, this, Row.getCPtr(row), row);
  }

  public void updateRow(Row row) {
    EsriFileGdbJNI.Table_updateRow(swigCPtr, this, Row.getCPtr(row), row);
  }

  public void deleteRow(Row row) {
    EsriFileGdbJNI.Table_deleteRow(swigCPtr, this, Row.getCPtr(row), row);
  }

  public EnumRows search(String subfields, String whereClause, Envelope envelope, boolean recycling) {
    long cPtr = EsriFileGdbJNI.Table_search__SWIG_0(swigCPtr, this, subfields, whereClause, Envelope.getCPtr(envelope), envelope, recycling);
    return (cPtr == 0) ? null : new EnumRows(cPtr, true);
  }

  public EnumRows search(String subfields, String whereClause, boolean recycling) {
    long cPtr = EsriFileGdbJNI.Table_search__SWIG_1(swigCPtr, this, subfields, whereClause, recycling);
    return (cPtr == 0) ? null : new EnumRows(cPtr, true);
  }

  public void setLoadOnlyMode(boolean loadOnly) {
    EsriFileGdbJNI.Table_setLoadOnlyMode(swigCPtr, this, loadOnly);
  }

  public void setWriteLock() {
    EsriFileGdbJNI.Table_setWriteLock(swigCPtr, this);
  }

  public void freeWriteLock() {
    EsriFileGdbJNI.Table_freeWriteLock(swigCPtr, this);
  }

}
