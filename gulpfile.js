import LocateJavaHome from 'locate-java-home';
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
let javaHome='/Library/Java/Home';
LocateJavaHome({
  version: "=1.8",
  mustBeJDK: true
}, function(error, javaHomes) {
  javaHome = javaHomes[0]
});

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
    gulp.src('target/FileGDB_API-64clang/lib/libfgdbunixrtl.dylib')
    .pipe(rename(`libfgdbunixrtl-${version}.dylib`))
    .pipe(gulp.dest('target/classes/natives/osx_64')),

    gulp.src('target/FileGDB_API-64clang/lib/libFileGDBAPI.dylib')
      .pipe(rename(`libFileGDBAPI-${version}.dylib`))
      .pipe(gulp.dest('target/classes/natives/osx_64')),
    
    gulp.src('target/FileGDB_API-64/lib/libfgdbunixrtl.so')
      .pipe(rename(`libfgdbunixrtl-${version}.so`))
      .pipe(gulp.dest('target/classes/natives/linux_64')),

    gulp.src('target/FileGDB_API-64/lib/libFileGDBAPI.so')
      .pipe(rename(`libFileGDBAPI-${version}.so`))
      .pipe(gulp.dest('target/classes/natives/linux_64')),

    gulp.src('target/FileGDB_API-VS2017/bin64/Esri.FileGDBAPI.dll')
      .pipe(rename(`Esri.FileGDBAPI-${version}.dll`))
      .pipe(gulp.dest('target/classes/natives/windows_64')),

    gulp.src('target/FileGDB_API-VS2017/bin64/FileGDBAPI.dll')
      .pipe(rename(`FileGDBAPI-${version}.dll`))
      .pipe(gulp.dest('target/classes/natives/windows_64'))
  ]);
});

gulp.task('swigDirectories', ()=> {
  for (var dir of [
    'target/cpp/',
    'target/java',
    'target/java/com', 
    'target/java/com/revolsys', 
    'target/java/com/revolsys/esri', 
    'target/java/com/revolsys/esri/filegdb', 
    'target/java/com/revolsys/esri/filegdb/api'
  ]) {
    if(!fs.existsSync(dir)) {
      fs.mkdirSync(dir)
    }
  }
});
gulp.task('swig', run('swig -c++ -o target/cpp/EsriFileGdb_wrap.cpp -java -package com.revolsys.esri.filegdb.api -outdir target/java/com/revolsys/esri/filegdb/api -Isrc/main/swig -Itarget/FileGDB_API-64/include src/main/swig/EsriFileGdbAPI.i', {
}));

gulp.task('compileOSX', run(
  `clang++ -W -fexceptions -fPIC -O3 -m64 -DUNICODE -D_UNICODE -DUNIX -D_REENTRANT -DFILEGDB_API -D__USE_FILE_OFFSET64 -DUNIX_FILEGDB_API -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE "-I${javaHome}/include/" "-I${javaHome}/include/darwin" "-Itarget/FileGDB_API-64clang/include" -stdlib=libc++ -c target/cpp/EsriFileGdb_wrap.cpp -o target/cpp/EsriFileGdb_wrap.o`
));

gulp.task('linkOSX', run(
  `clang++ -lFileGDBAPI -stdlib=libc++ -Ltarget/FileGDB_API-64clang/lib -shared -o target/classes/natives/osx_64/libEsriFileGdbJni-${version}.dylib target/cpp/EsriFileGdb_wrap.o`
));

gulp.task('compileLinux', run(
  `clang++ -W -fexceptions -fPIC -O3 -m64 -DUNICODE -D_UNICODE -DUNIX -D_REENTRANT -DFILEGDB_API -D__USE_FILE_OFFSET64 -DUNIX_FILEGDB_API -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE "-I${javaHome}/include/" "-I${javaHome}/include/linux" -DLINUX_CLANG -std=c++11 -stdlib=libstdc++ -Wno-narrowing -c target/cpp/EsriFileGdb_wrap.cpp -o target/cpp/EsriFileGdb_wrap.o`
));

gulp.task('linkLinux', run(
  `clang++ -lFileGDBAPI -v -stdlib=libstdc++ -lpthread -lrt -Ltarget/FileGDB_API-64/lib -shared -o target/classes/natives/linux_64/libEsriFileGdbJni-${version}.so target/cpp/EsriFileGdb_wrap.o`
));

gulp.task('mavenInstall', run('mvn install', {
}));

gulp.task('default', gulpSequence(
  'mavenClean',
  'downloadEsriOSX',
  'downloadEsriLinux',
  'downloadEsriWindows',
  'unzipEsriWindows',
  'copyEsriLibs',
  'swigDirectories',
  'swig'
));
