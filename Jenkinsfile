pipeline {
    agent none

    tools{
        maven 'mymaven'
    }

    parameters{
         
        string(name:'Env',defaultValue:'Test',description:'version to deploy')
        booleanParam(name:'executeTests',defaultValue: true,description:'decide to run tc')
        choice(name:'APPVERSION',choices:['1.1','1.2','1.3'])
    
    }
    environment{
        DEV_SERVER='ec2-user@172.31.40.95'
        IMAGE_NAME='isukapallisurya/surya:$BUILD_NUMBER'
        DEPLOY_SERVER='ec2-user@172.31.33.214'

    }

    stages {
        stage('Compile') {
            agent any
            steps {
                echo "Compiling the code in ${params.Env}"
                sh "mvn compile"
            }
        }
        stage('Unit Test') {
            agent any
            when{
                expression{
                    params.executeTests == true
                }
            }
            steps {
                script{
                
                echo 'Testing the code'
                sh "mvn test"
               
            }
            }    
        }
        stage('Dockerize and push the image') {
            agent any
            steps {
                script{
                sshagent(['slave2']) {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'password', usernameVariable: 'username')]) {
                echo "Packing the code ${params.APPVERSION}"
                sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEV_SERVER}:/home/ec2-user"
               sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER} /home/ec2-user/server-script.sh ${IMAGE_NAME}"
               sh "ssh ${DEV_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
               sh "ssh ${DEV_SERVER} sudo docker push ${IMAGE_NAME}"
            }
            }
            }
        }
        
    }
    
}
}
