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
        // here we are defining the environment variables to create a docker image on linux machine using ssh aggent slave private key
        DEV_SERVER='ec2-user@172.31.42.3'
        // Here i want to push the image to my repositry so i have give the my dockerregistry/repo name BUILD_NUMBER is predefined 
        // variable from jenkins which will give count of build we are taking it as tag
        IMAGE_NAME='isukapallisurya/surya:$BUILD_NUMBER'
        // here is the instance where i am creating the container
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
                    // here i am creating the docker image in slave machine using private key creds which i was configured in jenkins cred manager
                    sshagent(['slave2']) {

                        // withCredential manager is used to take  the creds which we stored in the credential manager(here we are taking docker creds)
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                            echo "Dockerize the Code ${params.APPVERSION}"
                            // with the below line we are copying the ssh script file from the master to dev server into home ec2-user dir.
                            sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEV_SERVER}:/home/ec2-user"
                            // with the below line we are are executing the copied script by passing the image name as argument.
                            sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER} bash /home/ec2-user/server-script.sh ${IMAGE_NAME}"
                            // the above command will clone the repositry and creeate the image for that code using docker file
                            // with the below command we are logging into the docker
                            sh "ssh ${DEV_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                            // here we are pushing the image to the repositry
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
                            // here we are not copying the script directly we are executing the commands to install commands because image is aleady created
                            sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} sudo yum install docker -y"
                            sh "ssh ${DEPLOY_SERVER} sudo systemctl start docker"
                            sh "ssh ${DEPLOY_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                            // this command will take pull from the docker repo and create a container for it.
                            sh "ssh ${DEPLOY_SERVER} sudo docker run -itd -P ${IMAGE_NAME}"
                        }
                    }
                }
            }
        }
    }
}
