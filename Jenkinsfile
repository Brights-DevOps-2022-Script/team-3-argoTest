pipeline {
  environment {
        GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        GIT_AUTHOR = sh(returnStdout: true, script: 'git log -1 --pretty=format:"%an"').trim()
        GIT_MSG = sh(returnStdout: true, script: 'git log -1 --pretty=format:"%s"').trim()
  }
   kaputt
  agent any
  stages {
    stage('Infos') {
      steps {
        sh """
          echo "Git Author: ${GIT_AUTHOR}"
          echo "Git Commit: ${GIT_COMMIT}"
          echo "Git Message: ${GIT_MSG}"
        """
      }
    }
    stage('BUILD + PUSH DOCKER IMAGE') {
      steps {
        script {
          if (env.GIT_USER == 'Jenkins') {
            return
          }
        }
        withDockerRegistry(credentialsId: 'acr_creds', url: 'https://devops2022.azurecr.io/v2/') {
          sh "docker build -t devops2022.azurecr.io/nginxanis:$GIT_COMMIT ."
          sh "docker push devops2022.azurecr.io/nginxanis:$GIT_COMMIT"
          sh "docker rmi devops2022.azurecr.io/nginxanis:$GIT_COMMIT"
        }
      }
    }
    stage('TEST DOCKER IMAGE') {
      steps {
        script {
          if (env.GIT_USER == 'Jenkins') {
            return
          }
        }
        script {
          def imageTag = "nginxanis:$GIT_COMMIT"
          def acrLoginServer = "devops2022.azurecr.io"
          def imageExists = sh(script: "set +x curl -fL ${acrLoginServer}/v2/manifests/${imageTag}", returnStatus: true) == 0
          if (!imageExists) {
            error("The image ${imageTag} was not found in the registry ${acrLoginServer}")
          }
        }
      }
    }
    stage('DEPLOY DEPLOYMENT FILE') {
      steps {
        script {
          if (env.GIT_USER == 'Jenkins') {
            return
          }
        }
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '2eb747c4-f19f-4601-ab83-359462e62482',  url: 'https://github.com/Brights-DevOps-2022-Script/team-3-argoTest.git']]])
        withCredentials([usernamePassword(credentialsId: '2eb747c4-f19f-4601-ab83-359462e62482', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
          sh("git pull https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Brights-DevOps-2022-Script/team-3-argoTest.git HEAD:main")
          sh("git checkout main")
          sh("""
            echo 'apiVersion: kustomize.config.k8s.io/v1beta1
            kind: Kustomization
            resources:
              - nginx.yml
            images:
              - name: ANIS-NGINX
            newName: devops2022.azurecr.io/nginxanis:${GIT_COMMIT}' > ./kustomization.yml
          """)
          sh("git add ./kustomization.yml")
          sh("git commit -m 'kustom [skip ci]'")
          sh("git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Brights-DevOps-2022-Script/team-3-argoTest.git HEAD:main")
        }
      }
    }
    stage('DEPLOY DEPLOYMENT FILE2') {
      steps {
        script {
          if (env.GIT_USER == 'Jenkins') {
            return
          }
        }
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'MessageExclusion', excludedMessage: '.*\\[skip ci\\].*']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '2eb747c4-f19f-4601-ab83-359462e62482',  url: 'https://github.com/Brights-DevOps-2022-Script/team-3-argoTest.git']]])
        withCredentials([usernamePassword(credentialsId: '2eb747c4-f19f-4601-ab83-359462e62482', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
        
        sh("echo PUSH2")
        sh("git pull https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Brights-DevOps-2022-Script/team-3-argoTest.git HEAD:main")
        sh("git checkout main")
        sh("""
          echo 'apiVersion: kustomize.config.k8s.io/v1beta1
          kind: Kustomization
          resources:
            - nginx.yml
          images:
            - name: ANIS-NGINX
          newName: devops2022.azurecr.io/nginxanis:${GIT_COMMIT}' > kustomization.yml
        """)  
        sh("git add kustomization.yml")
        sh("git commit -m 'kustomization [skip ci]'")
        sh("git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Brights-DevOps-2022-Script/team-3-argoTest.git HEAD:main")
      }
    }
  }
}
}
