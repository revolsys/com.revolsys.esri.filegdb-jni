def checkoutBranch(folderName, url, branchName) {
  dir(folderName) {
    deleteDir()
    checkout([
      $class: 'GitSCM',
      branches: [[name: branchName]],
      doGenerateSubmoduleConfigurations: false,
      extensions: [],
      gitTool: 'Default',
      submoduleCfg: [],
      userRemoteConfigs: [[url: url]]
    ])
  }
}

node ('linux') {
  def rtMaven = Artifactory.newMavenBuild()
  def buildInfo

  stage ('SCM globals') {
     sh '''
git config --global user.email "paul.austin@revolsys.com"
git config --global user.name "Paul Austin"
     '''
  }

  stage ('Checkout') {
    checkoutBranch('source', 'ssh://git@github.com/revolsys/com.revolsys.filegdb.api.git', 'master');
  }
  
  stage ('Cross Platform') {
    dir ('source') {
      sh '''
npm install
gulp
      '''
    }
  }
  
  stage ('Native Library Build') {

    stash includes: '''
      source/gulpfile.js,
      source/package.json,
      source/package-lock.json,
      source/target/cpp/EsriFileGdb_wrap.cpp
    ''', name: 'shared';

    stash includes: '''
      source/target/FileGDB_API-64clang/include/**,
      source/target/FileGDB_API-64clang/lib/**
    ''', name: 'osx';

    stash includes: '''
      source/build-winnt.bat,
      source/Makefile.nmake,
      source/target/FileGDB_API-VS2015/include/**,
      source/target/FileGDB_API-VS2015/bin64/**
    ''', name: 'windows';

    node ('macosx') {
      env.NODEJS_HOME = "${tool 'node-latest'}"
      env.PATH="${env.NODEJS_HOME}/bin:${env.PATH}"
     
      unstash 'shared';
      unstash 'osx';
      dir ('source') {
        sh '''
npm install
gulp compileOSX linkOSX
      '''
      }
      stash includes: '''
        source/target/classes/natives/osx_64/**
      ''', name: 'osxLib';
    }
    
    node ('windows') {
      env.PATH = env.PATH + ";c:\\Windows\\System32"
      unstash 'shared';
      unstash 'windows';
      dir ('source') {
        bat 'build-winnt.bat'
      }
      stash includes: '''
        source/target/classes/natives/windows_64/**
      ''', name: 'windowsLib';
    }
    
    sh 'gulp compileLinux linkLinux'
    
    unstash 'osxLib'
    unstash 'windowsLib'
    dir ('source') {
      sh 'gulp mavenInstall'
    }
  }
}
