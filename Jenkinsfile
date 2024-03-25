pipeline {
    agent any
    
    stages{
        stage("Fetch git code"){
            steps {
                // git branch : 'paac', url:'https://github.com/computedev/Devops-tools.git'
                git branch : 'paac', url:'https://github.com/devopshydclub/vprofile-project.git'
            }
        }
        stage('clean'){
            steps{
                sh 'mvn clean'
            }
        }
        stage('Build and Test'){
            steps{
                sh 'mvn install'
                // bat 'mvn install' // windows
                //sh 'java -version'
            }
        }
        stage('test'){
            steps{
                sh 'mvn test'
                // bat 'mvn test' // windows 
            }
        }
        stage('Checkstyle Analysis'){
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }
        stage('sonar Analysis'){
            environment{
                scannerHome= tool 'sonar-16'
            }
                steps{
                    withSonarQubeEnv('My SonarQube Server'){
                        sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=Devops-tools \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/test-classes/com/com.niranjan-webapp-group/account/controllerTest/ \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                    }

                }
            }
    }
    
}