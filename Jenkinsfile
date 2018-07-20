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
    
    unstash 'osxLib'
    sh 'find source/target/classes/natives/'
      dir ('source') {
        sh 'gulp mavenInstall'
      }
  }
}
