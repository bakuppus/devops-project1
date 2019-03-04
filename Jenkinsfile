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

        stage("build & SonarQube analysis") {
           steps {
               sh 'mvn clean package sonar:sonar'
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
                    "pattern": "target/*.war",
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


          def buildInfo = Artifactory.newBuildInfo()
          def tagDockerApp

          //Clone example project from GitHub repository
          git url: 'https://github.com/bakuppus/devops-project1.git', branch: 'development'

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
              script {

              def SERVICE_NAME
               //userid
               sh "id"

               // Validate kubectl
               sh "kubectl cluster-info"

               // Init helm client
               sh "helm init"

               //Install dev
               sh "helm delete --purge devserver"
               sh "sleep 5"

              //Install dev
              sh "helm install devapp --name devserver"

              //Get Service IP
              sh "sleep 5"
              sh "sh networkinfo.sh"


             }
           }
         }

         ////////// Step 2 //////////
         stage('Deploy to tomcat8') {
             steps {
                script {
                sh "sh deploy-to-dev.sh"
         }
        }
       }
     //////// Slack Notification /////////
        //stage('slack notify') {
          //steps {

            node {
                 try {
                 def notifySlack(String buildStatus = 'STARTED') {
                   // Build status of null means success.
                   buildStatus = buildStatus ?: 'SUCCESS'

                   def color

                   if (buildStatus == 'STARTED') {
                       color = '#D4DADF'
                   } else if (buildStatus == 'SUCCESS') {
                       color = '#BDFFC3'
                   } else if (buildStatus == 'UNSTABLE') {
                       color = '#FFFE89'
                   } else {
                       color = '#FF9FA1'
                   }

                   def msg = "${buildStatus}: `${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL}"

                   slackSend(color: color, message: msg)


              }
            }
               node {
                   try {
                       notifySlack()

                       // Existing build steps.
                   } catch (e) {
                       currentBuild.result = 'FAILURE'
                       throw e
                   } finally {
                       notifySlack(currentBuild.result)
                   }
               }

            }

        //  }
      //  }


    }
}
