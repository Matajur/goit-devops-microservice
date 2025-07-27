pipeline {
  agent any

  environment {
    AWS_REGION = 'eu-central-1'
    ECR_REPO = '375004071644.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr'
    IMAGE_TAG = "${env.BUILD_ID}"
    GIT_REPO = 'https://github.com/Matajur/goit-devops-microservice.git'
    BRANCH = 'django-app'
    CHART_PATH = 'charts/django-app/values.yaml'
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: "${env.BRANCH}", url: "${env.GIT_REPO}"
      }
    }

    stage('Build Docker Image with Kaniko') {
      steps {
        container('kaniko') {
          withEnv([
            "DOCKER_CONFIG=/kaniko/.docker/"
          ]) {
            sh '''
              /kaniko/executor \
                --context ${WORKSPACE}/django-app \
                --dockerfile ${WORKSPACE}/django-app/Dockerfile \
                --destination=375004071644.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:1 \
                --insecure \
                --skip-tls-verify \
                --cache=true
            '''
          }
        }
      }
    }

    stage('Push to ECR') {
      steps {
        script {
          sh """
            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
            docker push $ECR_REPO:$IMAGE_TAG
          """
        }
      }
    }

    stage('Update Helm values.yaml') {
      steps {
        script {
          sh """
            sed -i 's|repository: .*|repository: ${ECR_REPO}|' ${CHART_PATH}
            sed -i 's|tag: .*|tag: ${IMAGE_TAG}|' ${CHART_PATH}
          """
        }
      }
    }

    stage('Push Changes to GitHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
          sh """
            git config user.name "jenkins"
            git config user.email "jenkins@example.com"
            git add ${CHART_PATH}
            git commit -m "Update image tag to ${IMAGE_TAG}"
            git push https://${GIT_USER}:${GIT_PASS}@github.com/Matajur/goit-devops-microservice.git ${BRANCH}
          """
        }
      }
    }
  }
}
