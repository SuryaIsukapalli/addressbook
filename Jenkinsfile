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

    }

    stages {
        stage('Compile') {
            agent any
            steps {
                echo "Compiling the code in ${params.Env}"
                sh "mvn compile"
            }
        }
        stage('Unitest') {
            agent any
            when{
                expression{
                    params.executeTests == true
                }
            }
            steps {
                script{
                sshagent(['slave2']) {
                echo 'Testing the code'
               sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEV_SERVER}:/home/ec2-user"
               sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER} 'bash ~/server-script.sh'"
            }
            }    
            }
        }
        stage('Package') {
            agent {label 'linux_slave'}
            input{
                message "select the version to deploy"
                ok "version selected"
                parameters {
                    choice(name: 'NEWAPP', choices: ['1.1', '1.2', '1.3'])
                }
            }
            steps {
                echo "Packing the code ${params.APPVERSION}"
                sh "mvn package"
            }
        }
        
    }
    
}
