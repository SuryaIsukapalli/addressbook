pipeline {
    agent none

    tools {
        maven 'mymaven'
    }

    parameters {
        string(name: 'Env', defaultValue: 'Test', description: 'version to deploy')
        booleanParam(name: 'executeTests', defaultValue: true, description: 'decide to run tc')
        choice(name: 'APPVERSION', choices: ['1.1', '1.2', '1.3'])
    }

    environment {
        DEV_SERVER='ec2-user@172.31.42.3'
        IMAGE_NAME='isukapallisurya/surya:$BUILD_NUMBER'
        DEPLOY_SERVER='ec2-user@172.31.33.214'
    }

    stages {
        stage('Compile') {
            agent any
            steps {
                echo "Compiling the Code in ${params.Env}"
                sh "mvn compile"
            }
        }
        stage('UnitTest') {
            agent any
            when {
                expression {
                    params.executeTests == true
                }
            }
            steps {
                echo 'Test the Code'
                sh "mvn test"
            }

        }

        stage('Dockerize and push the image') {
            agent any
            steps {
                script {
                    sshagent(['slave2']) {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                            echo "Dockerize the Code ${params.APPVERSION}"
                            sh "scp -o StrictHostKeyChecking=no ${DEV_SERVER}:/home/ec2-user"
                            sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER} bash /home/ec2-user/server-script.sh ${IMAGE_NAME}"
                            sh "ssh ${DEV_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                            sh "ssh ${DEV_SERVER} sudo docker push ${IMAGE_NAME}"
                        }
                    }
                }
            }
        }
        stage('Deploy the docker image') {
            agent any
            steps {
                script {
                    sshagent(['slave2']) {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                            echo "Run the docker container"
                            sh "ssh -o StrictHostKeyChecking=no server-script.sh ${DEPLOY_SERVER} sudo yum install docker -y"
                            sh "ssh ${DEPLOY_SERVER} sudo systemctl start docker"
                            sh "ssh ${DEPLOY_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                            sh "ssh ${DEPLOY_SERVER} sudo docker run -itd -P ${IMAGE_NAME}"
                        }
                    }
                }
            }
        }
    }
}
