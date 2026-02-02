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

    choice(
      name: 'TF_ACTION',
      choices: ['apply', 'destroy'],
      description: 'Terraform action to perform'
    )
  }

  environment {
    TF_IN_AUTOMATION   = "true"
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
      when {
        expression { params.TF_ACTION == 'apply' }
      }
      steps {
        dir("envs/${params.ENV}") {
          sh 'terraform fmt -check -recursive'
        }
      }
    }

    stage('Terraform Validate') {
      when {
        expression { params.TF_ACTION == 'apply' }
      }
      steps {
        dir("envs/${params.ENV}") {
          sh 'terraform validate'
        }
      }
    }

    stage('Terraform Plan') {
      when {
        expression { params.TF_ACTION == 'apply' }
      }
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

    stage('Manual Approval (Apply)') {
      when {
        allOf {
          expression { params.TF_ACTION == 'apply' }
          expression { params.ENV == 'prod' }
        }
      }
      steps {
        input message: "Approve Terraform APPLY for ${params.ENV}?"
      }
    }

    stage('Terraform Apply') {
      when {
        expression { params.TF_ACTION == 'apply' }
      }
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

    stage('Manual Approval (Destroy)') {
      when {
        expression { params.TF_ACTION == 'destroy' }
      }
      steps {
        input message: "⚠️ CONFIRM Terraform DESTROY for ${params.ENV} ⚠️"
      }
    }

    stage('Terraform Destroy') {
      when {
        expression { params.TF_ACTION == 'destroy' }
      }
      steps {
        withCredentials([
          [$class: 'AmazonWebServicesCredentialsBinding',
           credentialsId: 'aws-prod-creds']
        ]) {
          dir("envs/${params.ENV}") {
            sh '''
              terraform destroy \
                -input=false \
                -auto-approve
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "Terraform ${params.TF_ACTION.toUpperCase()} SUCCESSFUL for ${params.ENV}"
    }
    failure {
      echo "Terraform ${params.TF_ACTION.toUpperCase()} FAILED for ${params.ENV}"
    }
    always {
      cleanWs()
    }
  }
}
