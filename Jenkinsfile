// parameters
// ----------
// gitTag

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

def setVersion(folderName, prefix) {
  def tagName = "${gitTag}";
  if (prefix != null) {
    tagName = "${prefix}-${gitTag}";
  }
  dir(folderName) {
    sh "git checkout -B version-${tagName}"
    withMaven(jdk: 'jdk', maven: 'm3') {
      sh "mvn versions:set -DnewVersion='${tagName}' -DgenerateBackupPoms=false"
    }
  }
}

def tagVersion(folderName, prefix) {
  def tagName = "${gitTag}";
  if (prefix != null) {
    tagName = "${prefix}-${gitTag}";
  }
  dir(folderName) {
    sh """
git commit -a -m "Version ${tagName}"
git tag -f -a ${tagName} -m "Version ${tagName}"
git push origin ${tagName}
    """
  }
}

node ('master') {
  def rtMaven = Artifactory.newMavenBuild()
  def buildInfo

  stage ('SCM globals') {
     sh '''
git config --global user.email "paul.austin@revolsys.com"
git config --global user.name "Paul Austin"
     '''
  }

  stage ('Checkout') {
    checkoutBranch('revolsys', 'ssh://git@github.com:revolsys/com.revolsys.filegdb.api.git', 'master');
    checkoutBranch('esri', 'https://github.com/Esri/file-geodatabase-api.git', 'master');
  }
/*
  stage ('Set Project Versions') {
    setVersion('revolsys', 'GBA');
    setVersion('gba', null);
  }

  stage ('Tag') {
    tagVersion('revolsys', 'GBA');
    tagVersion('gba', null);
  }
  */
}
