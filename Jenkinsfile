pipeline {
    agent any

    environment {
        TAG = sh(script: 'git describe --abbrev=0',,returnStdout: true).trim()
    }

    stages {

         stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                script {
                    sh """
                        echo "registry=http://localhost:8091/repository/npm-public/" > ~/.npmrc
                    """
                    sh 'npm config list'
                    sh 'npm config get registry'
                    sh 'npm install --verbose'
                }
            }
        }


        stage('build docker image'){
        steps{
            sh 'docker build -t angular-hello/app:${TAG} .'
            }
        }

        stage('sleep for container deploy'){
        steps{
            sh 'sleep 10'
            }
        }

        stage('Sonarqube validation'){
            steps{
                script{
                    scannerHome = tool 'sonar-scanner';
                }
                withSonarQubeEnv('sonar-server'){
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=angular-hello -Dsonar.sources=. -Dsonar.host.url=${env.SONAR_HOST_URL} -Dsonar.token=${env.SONAR_AUTH_TOKEN} -X"
                }
                sh 'sleep 10'
            }
        }

        stage("Quality Gate"){
            steps{
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Upload docker image'){
            steps{
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexus-user', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh 'docker login -u $USERNAME -p $PASSWORD ${NEXUS_URL}'
                        sh 'docker tag angular-hello/app:${TAG} ${NEXUS_URL}/angular-hello/app:${TAG}'
                        sh 'docker push ${NEXUS_URL}/angular-hello/app:${TAG}'
                    }
                }
            }
        }

        stage("Apply kubernetes files"){
            steps{
                sh '/usr/local/bin/kubectl apply -f ./kubernetes/angular-hello.yaml'
            }
        }
    }
}