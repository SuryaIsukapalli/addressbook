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
                echo 'Testing the code'
                sh "mnv test"
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
