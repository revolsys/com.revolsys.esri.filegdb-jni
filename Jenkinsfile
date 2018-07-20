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
    dir ('source') {
      stash includes: '''
        gulpfile.js,
        package.json,
        target/FileGDB_API-64clang/include,
        target/cpp/EsriFileGdb_wrap.cpp
      ''', name: 'osx';
    }
    node ('macosx') {
      env.NODEJS_HOME = "${tool 'Node 10.x'}"
      env.PATH="${env.NODEJS_HOME}/bin:${env.PATH}"
     
      unstash: 'osx';
      sh '''
npm install
gulp compileOSX
      '''
    }
  }
}
