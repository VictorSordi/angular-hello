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
                echo "//${NEXUS_URL_NODE}:_auth=amVua2luczpKM25rMW5zQA==" > ~/.npmrc
                echo "//${NEXUS_URL_NODE}:_authToken=NpmToken.04bc8815-3d62-30a4-9e8f-369c17ba9cd6" > ~/.npmrc
                echo "registry=${NEXUS_URL_NODE}" >> ~/.npmrc
                sh 'npm install'
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
                        sh 'docker login -u $USERNAME -p $PASSWORD ${NEXUS_URL_DOCKER}'
                        sh 'docker tag angular-hello/app:${TAG} ${NEXUS_URL_DOCKER}/angular-hello/app:${TAG}'
                        sh 'docker push ${NEXUS_URL_DOCKER}/angular-hello/app:${TAG}'
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