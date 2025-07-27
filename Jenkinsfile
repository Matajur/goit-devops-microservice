pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
      volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker
  volumes:
    - name: kaniko-secret
      secret:
        secretName: kaniko-docker-config
"""
    }
  }

  environment {	
    ECR_REGISTRY = "375004071644.dkr.ecr.eu-central-1.amazonaws.com"
    IMAGE_NAME   = "lesson-5-ecr"
    IMAGE_TAG    = "latest"
  }

  stages {
    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context=$(pwd) \
              --dockerfile=$(pwd)/Dockerfile \
              --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \
              --cache=true \
              --insecure \
              --skip-tls-verify
          '''
        }
      }
    }
  }
}
