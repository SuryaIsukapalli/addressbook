pipeline {
    agent any

    parameters{
         
        string(name:'Env',defaultValue:'Test',description:'version to deploy')
        booleanParam(name:'executeTests',defaultValue: true,description:'decide to run tc')
        choice(name:'APPVERSION',choices:['1.1','1.2','1.3'])
    
    }

    stages {
        stage('Compile') {
            steps {
                echo "Compiling the code in ${params.Env}"
            }
        }
        stage('Unitest') {
            when{
                expression{
                    params.executeTests == true
                }
            }
            steps {
                echo 'Testing the code'
            }
        }
        stage('Package') {
            steps {
                echo "Packing the code ${params.APPVERSION}"
            }
        }
        
    }
    
}
