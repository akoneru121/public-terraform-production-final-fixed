pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    timestamps()
  }

  parameters {
    choice(
      name: 'ENV',
      choices: ['dev', 'prod'],
      description: 'Select Terraform environment'
    )
  }

  environment {
    TF_IN_AUTOMATION = "true"
    AWS_DEFAULT_REGION = "us-east-1"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding',
           credentialsId: 'aws-prod-creds']
        ]) {
          dir("envs/${params.ENV}") {
            sh '''
              terraform init \
                -input=false \
                -reconfigure
            '''
          }
        }
      }
    }

    stage('Terraform Format Check') {
      steps {
        dir("envs/${params.ENV}") {
          sh 'terraform fmt -check -recursive'
        }
      }
    }

    stage('Terraform Validate') {
      steps {
        dir("envs/${params.ENV}") {
          sh 'terraform validate'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding',
           credentialsId: 'aws-prod-creds']
        ]) {
          dir("envs/${params.ENV}") {
            sh '''
              terraform plan \
                -input=false \
                -out=tfplan
            '''
          }
        }
      }
    }

    stage('Manual Approval') {
      when {
        expression { params.ENV == 'prod' }
      }
      steps {
        input message: "Approve Terraform apply for ${params.ENV}?"
      }
    }

    stage('Terraform Apply') {
      steps {
        withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding',
           credentialsId: 'aws-prod-creds']
        ]) {
          dir("envs/${params.ENV}") {
            sh '''
              terraform apply \
                -input=false \
                -auto-approve \
                tfplan
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "Terraform deployment SUCCESSFUL for ${params.ENV}"
    }
    failure {
      echo "Terraform deployment FAILED for ${params.ENV}"
    }
    always {
      cleanWs()
    }
  }
}