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

        stage('Test') {
          steps {
              sh 'mvn test'
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                }
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
                def server = Artifactory.server 'Jfrog'
                def rtMaven = Artifactory.newMavenBuild()
                def buildInfo
                server.bypassProxy = true
                rtMaven.tool = "maven3"
                rtMaven.deployer releaseRepo:'maven-local', snapshotRepo:'maven-snapshot', server: server

            def uploadSpec = """{
               "files": [
                  {
                    "pattern": "",
                    "target": "maven-snapshot/"
                   }
                  ]
                }"""
                server.upload(uploadSpec)
    }
  }
 }

 stage('Artifactory') {
  steps {

      script {
        node {

          // Cleanup workspace
          //deleteDir()

          //copy war
          //sh "cp -rf target/*.war ."

          def buildInfo = Artifactory.newBuildInfo()
          def tagDockerApp

          //Clone example project from GitHub repository
          git url: 'https://github.com/bakuppus/jenkinsfile-docker.git', branch: 'master'

          // Step 1: Obtain an Artifactiry instance, configured in Manage Jenkins --> Configure System:
          def server = Artifactory.server 'Jfrog'

          // Step 2: Create an Artifactory Docker instance:
          def rtDocker = Artifactory.docker server: server
          // Or if the docker daemon is configured to use a TCP connection:
          // def rtDocker = Artifactory.docker server: server, host: "tcp://<docker daemon host>:<docker daemon port>"
          // If your agent is running on OSX:
          // def rtDocker= Artifactory.docker server: server, host: "tcp://127.0.0.1:1234"
          tagDockerApp = "18.219.249.212:8081/kierandocker/tomcat8:latest"
          docker.build(tagDockerApp)

          server.bypassProxy = true
          // Step 3: Push the image to Artifactory.
          // Make sure that <artifactoryDockerRegistry> is configured to reference <targetRepo> Artifactory repository. In case it references a different repository, your build will fail with "Could not find manifest.json in Artifactory..." following the push.
          buildInfo = rtDocker.push "$tagDockerApp", 'kierandocker'

          // Step 4: Publish the build-info to Artifactory:
          server.publishBuildInfo buildInfo
      }
  }
 }
 }


       ////////// Step 1 //////////
       stage('K8s and helm  checkup') {
           steps {
               //userid
               sh "id"

               // Validate kubectl
               sh "kubectl cluster-info"

               // Init helm client
               sh "helm init"

              //Install dev
              sh "helm install devapp --name devserver"
           }
         }



    }
}
