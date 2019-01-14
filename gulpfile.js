var gulp = require('gulp');
var download = require("gulp-download");
var decompress = require('gulp-decompress')
var unzip = require('gulp-unzip')
var run = require('gulp-run-command').default;
var rename = require('gulp-rename');
var gulpSequence = require('gulp-sequence')
const fs   = require('fs');

const version = '1.5.1';
const version_ = version.replace(/\./g, '_');
const baseUrl = `https://raw.githubusercontent.com/Esri/file-geodatabase-api/master/FileGDB_API_${version}/`;
const filePrefix = `FileGDB_API_${version_}-` ;

gulp.task('downloadEsriOSX', function() {
  return download(baseUrl + filePrefix + '64clang.zip')
    .pipe(unzip())
    .pipe(gulp.dest('target/'));
});

gulp.task('downloadEsriLinux', function() {
  return download(baseUrl + filePrefix + '64.tar.gz')
    .pipe(decompress())
    .pipe(gulp.dest('target/'));
});

gulp.task('downloadEsriWindows', function() {
  return download(baseUrl + filePrefix + 'VS2017.zip')
    .pipe(gulp.dest('target/'));
});

gulp.task('unzipEsriWindows', function() {
  return gulp.src('target/' + filePrefix + 'VS2017.zip')
    .pipe(unzip())
    .pipe(gulp.dest('target/FileGDB_API-VS2017'));
});

gulp.task('mavenClean', run('mvn clean', {
}));

gulp.task('copyEsriLibs', ()=> {
  return Promise.all([
    gulp.src('target/FileGDB_API-64/lib/libfgdbunixrtl.so')
      .pipe(rename(`libfgdbunixrtl.so`))
      .pipe(gulp.dest('target/classes/natives/linux_64')),

    gulp.src('target/FileGDB_API-64/lib/libFileGDBAPI.so')
      .pipe(rename(`libFileGDBAPI.so`))
      .pipe(gulp.dest('target/classes/natives/linux_64')),

    gulp.src('target/FileGDB_API-64clang/lib/libfgdbunixrtl.dylib')
      .pipe(rename(`libfgdbunixrtl.dylib`))
      .pipe(gulp.dest('target/classes/natives/osx_64')),

    gulp.src('target/FileGDB_API-64clang/lib/libFileGDBAPI.dylib')
      .pipe(rename(`libFileGDBAPI.dylib`))
      .pipe(gulp.dest('target/classes/natives/osx_64')),

    gulp.src('target/FileGDB_API-VS2017/bin64/Esri.FileGDBAPI.dll')
      .pipe(rename(`Esri.FileGDBAPI.dll`))
      .pipe(gulp.dest('target/classes/natives/windows_64')),

    gulp.src('target/FileGDB_API-VS2017/bin64/FileGDBAPI.dll')
      .pipe(rename(`FileGDBAPI.dll`))
      .pipe(gulp.dest('target/classes/natives/windows_64'))
  ]);
});

gulp.task('swigDirectories', ()=> {
  for (var dir of [
    'target/classes/',
    'target/classes/natives',
    'target/classes/natives/linux_64',
    'target/classes/natives/osx_64',
    'target/classes/natives/windows_64',
    'target/cpp/',
    'target/java',
    'target/java/com', 
    'target/java/com/revolsys', 
    'target/java/com/revolsys/esri', 
    'target/java/com/revolsys/esri/filegdb', 
    'target/java/com/revolsys/esri/filegdb/jni'
  ]) {
    if(!fs.existsSync(dir)) {
      fs.mkdirSync(dir)
    }
  }
});

gulp.task('swig', run('swig -c++ -o target/cpp/EsriFileGdb_wrap.cpp -java -package com.revolsys.esri.filegdb.jni -outdir target/java/com/revolsys/esri/filegdb/jni -Isrc/main/swig -Itarget/FileGDB_API-64/include src/main/swig/EsriFileGdbAPI.i', {
}));

gulp.task('compileOSX', run(
  `clang++ -W -fexceptions -fPIC -O3 -m64 -DUNICODE -D_UNICODE -DUNIX -D_REENTRANT -DFILEGDB_API -D__USE_FILE_OFFSET64 -DUNIX_FILEGDB_API -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE "-I$(JAVA_HOME)" "-I$(JAVA_HOME)/include/darwin" "-Itarget/FileGDB_API-64clang/include" -stdlib=libc++ -c target/cpp/EsriFileGdb_wrap.cpp -o target/cpp/EsriFileGdb_wrap.o`, {
    env: {
      JAVA_HOME: '/Library/Java/JavaVirtualMachines/openjdk-11.0.1.jdk/Contents/Home'
    }
  }
));

gulp.task('linkOSX', run([
  'mkdir -p target/classes/natives/osx_64/',
  `clang++ -lFileGDBAPI -stdlib=libc++ -Ltarget/FileGDB_API-64clang/lib -shared -o target/classes/natives/osx_64/libFileGdbJni.dylib target/cpp/EsriFileGdb_wrap.o`
]));

gulp.task('compileLinux', run(
  `clang++ -W -fexceptions -fPIC -O3 -m64 -DUNICODE -D_UNICODE -DUNIX -D_REENTRANT -DFILEGDB_API -D__USE_FILE_OFFSET64 -DUNIX_FILEGDB_API -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE "-I$(JAVA_HOME)/include/" "-I$(JAVA_HOME)/include/linux" "-Itarget/FileGDB_API-64/include" -DLINUX_CLANG -std=c++11 -stdlib=libstdc++ -Wno-narrowing -c target/cpp/EsriFileGdb_wrap.cpp -o target/cpp/EsriFileGdb_wrap.o`, {
    env: {
      JAVA_HOME: '=/usr/lib/jvm/java-11-openjdk-amd64'
    }
  }
));

gulp.task('linkLinux', run(
  `clang++ -lFileGDBAPI -v -stdlib=libstdc++ -lpthread -lrt -Ltarget/FileGDB_API-64/lib -shared -o target/classes/natives/linux_64/libFileGdbJni.so target/cpp/EsriFileGdb_wrap.o`
));

gulp.task('default', gulpSequence(
  'mavenClean',
  'downloadEsriLinux',
  'downloadEsriOSX',
  'downloadEsriWindows',
  'unzipEsriWindows',
  'copyEsriLibs',
  'swigDirectories',
  'swig'
));
