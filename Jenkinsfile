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
         stage('slack') {
             steps {
                script {
           node {
           def notifyBuild = { String buildStatus ->
               // build status of null means successful
               buildStatus =  buildStatus ?: 'SUCCESSFUL'

               // Default values
               def colorName = 'RED'
               def colorCode = '#FF0000'
               def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
               def summary = "${subject} (${env.BUILD_URL})"
               def details = """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
               <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

               // Override default values based on build status
               if (buildStatus == 'STARTED') {
                   color = 'YELLOW'
                   colorCode = '#FFFF00'
               } else if (buildStatus == 'SUCCESSFUL') {
                   color = 'GREEN'
                   colorCode = '#00FF00'
               } else {
                   color = 'RED'
                   colorCode = '#FF0000'
               }

               // Send notifications
               slackSend ( color: colorCode, message: summary)
           }



           stage ('Deploy to tomcat8') {
               try {
                   notifyBuild('STARTED')

                   steps {
                      script {
                      sh "sh deploy-to-dev.sh"
                    }
                  }

               } catch (e) {
                   // If there was an exception thrown, the build failed
                   currentBuild.result = "FAILED"
                   throw e
               } finally {
                   // Success or failure, always send notifications
                   notifyBuild(currentBuild.result)
               }
           }
         }
       }
      }
    }



    }
}
