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
  def artifactoryServer = Artifactory.server 'prod'
  def mavenRuntime = Artifactory.newMavenBuild()
  env.JAVA_HOME = '/usr/lib/jvm/java-11-openjdk-amd64'
  mavenRuntime.tool = 'm3' 
  mavenRuntime.deployer releaseRepo: 'libs-release-local', snapshotRepo: 'libs-snapshot-local', server: artifactoryServer
  mavenRuntime.resolver releaseRepo: 'repo', snapshotRepo: 'repo', server: artifactoryServer
  mavenRuntime.deployer.deployArtifacts = false
  def buildInfo = Artifactory.newBuildInfo()

  stage ('SCM globals') {
     sh '''
git config --global user.email "paul.austin@revolsys.com"
git config --global user.name "Paul Austin"
     '''
  }

  stage ('Checkout') {
    dir ('source') {
      deleteDir()
    }
    checkoutBranch('source', 'https://github.com/revolsys/com.revolsys.esri.filegdb-jni.git', 'master');
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
      source/target/FileGDB_API-VS2017/include/**,
      source/target/FileGDB_API-VS2017/lib64/**
    ''', name: 'windows';

    node ('macosx') {
      dir ('source') {
        deleteDir()
      }

      env.NODEJS_HOME = "${tool 'node-latest'}"
      env.PATH="${env.NODEJS_HOME}/bin:${env.PATH}"
      unstash 'shared';
      unstash 'osx';
      dir ('source') {
        sh '''
npm install
gulp compileOSX
gulp linkOSX
      '''
      }
      stash includes: '''
        source/target/classes/natives/osx_64/**
      ''', name: 'osxLib';
    }
    
    node ('windows') {
      dir ('source') {
        deleteDir()
      }

      env.PATH = env.PATH + ";c:\\Windows\\System32"
      unstash 'shared';
      unstash 'windows';
      dir ('source') {
        bat 'build-winnt.bat'
      }
      stash includes: '''
        source/target/classes/natives/windows_64/*.dll
      ''', name: 'windowsLib';
    }

    unstash 'osxLib'
    unstash 'windowsLib'

    dir ('source') {
      env.NODEJS_HOME = "${tool 'node-latest'}"
      env.PATH="${env.NODEJS_HOME}/bin:${env.PATH}"
      sh '''
npm install
gulp compileLinux
gulp linkLinux
      '''
    }
  
    stage('build') {
      dir ('source') {
        mavenRuntime.run pom: 'pom.xml', goals: 'install', buildInfo: buildInfo
      }
    }
    
    stage('deploy') {
      dir ('source') {
        mavenRuntime.deployer.deployArtifacts buildInfo
        artifactoryServer.publishBuildInfo buildInfo
      }
    }
  }
}
