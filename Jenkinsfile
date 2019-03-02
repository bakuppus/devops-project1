pipeline {
    agent any
      tools {
             jdk "jdk9"
             maven  "maven3.6"
       }
    stages {
        stage('Maven Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Maven Package') {
            steps {
                sh 'mvn package'
            }
        }


        stage('Artifactory configuration') {
           steps {
             script {
                def server = Artifactory.server 'server'
                def rtMaven = Artifactory.newMavenBuild()
                def buildInfo
                server.bypassProxy = true
                rtMaven.tool = "maven3"
                rtMaven.deployer releaseRepo:'maven-local', snapshotRepo:'maven-snapshot', server: Jfrog

            def uploadSpec = """{
               "files": [
                  {
                    "pattern": "target/*.war",
                    "target": "maven-snapshot/"
                   }
                  ]
                }"""
                server.upload(uploadSpec)
    }
  }
 }





    }
}
