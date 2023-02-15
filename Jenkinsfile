pipeline{

    environment {
        repo    = 'github.com/Brights-DevOps-2022-Script/repo-demo-marc.git'
        branch  = 'main'
        acr     = 'devops2022.azurecr.io'
        gitCred = '2eb747c4-f19f-4601-ab83-359462e62482'
        GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        GIT_AUTHOR = sh(returnStdout: true, script: 'git log -1 --pretty=format:"%an"').trim()
        GIT_MSG    = sh(returnStdout: true, script: 'git log -1 --pretty=format:"%s"').trim()
        // CHANGES    = sh(script: 'git diff HEAD^ --name-only ../frontend', returnStdout: true).trim()
        // Groovy variables in camelCase
        buildNo    = "${env.BUILD_NUMBER}"
        //tag        = "${GIT_COMMIT}"
        //tag        = "${env.BUILD_NUMBER}"
        imageTag   = "${image}:${tag}"
        // conditions
        isNewImage          = true
        isNonBuildRelease   = false
        isJenkins           = env.GIT_AUTHOR.equalsIgnoreCase('Jenkins')
    }

    agent any

    stages {

        stage('print Infos') {
          steps {
            script {
             println "Git Author        : ${GIT_AUTHOR}"
             println "Git Commit        : ${GIT_COMMIT}"
             println "is jenkins        : ${isJenkins}"
             println "ACR login Server  : ${acr}"
             println "Repo              : ${repo}"
             println "Images:"
             for (def image : images) {
                 println "  name: ${image['name']}, path: ${image['path']}, need update: ${image['needUpdate']}"
          }
        }
      }
    }

        stage('Docker image'){
           when { expression {images.any { image -> image.needUpdate }}}
             steps{
                script {
                 for (int i = 0; i < images.size(); i++) {
                   def image = images[i]
                  try {           
                  WithDockerRegistry([ credentialsId: 'acr_creds', url: "https://${arc}/v2/"]) {
                     sh "docker build -t ${acr}/${image.name}:${tag} ${image.path}"
                     sh "docker push ${acr}/${image.name}:${tag}"
                     sh "docker rmi ${acr}/${image.name}:${tag}"
                    }
                }
                    
                 catch (Exception e) {
                  println "Error building Docker image: ${e.getMessage()}"
                  currentBuild.result = 'FAILURE'
                  error "Failed to build Docker image for ${image.name}"
            }
          }
        }
      }
   }
       stage('DEPLOY DEPLOYMENT FILE') {
      when { expression { images.any { it.needUpdate } } }
          steps{
            script {
             withCredentials([usernamePassword(credentialsId: "${gitCred}", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
              checkout([
               $class: 'GitSCM',
               branches: [[name: '*/main']],
               doGenerateSubmoduleConfigurations: false,
               extensions: [],
               submoduleCfg: [],
               userRemoteConfigs: [[
               credentialsId: "${gitCred}",
               url: "https://${repo}"
              ]]
            ])
            sh "chmod +x './BashScripts/deployFile.sh'"
            for (int i = 0; i < images.size(); i++) {
              def image = images[i]
              if (image.needUpdate) {
                try {
                  sh "./BashScripts/deployFile.sh --name=${image.name} --newTag=${tag} --newName=${image.name} --repo=${repo}"
                } catch (Exception e) {
                  println "Error deploying deployment file: ${e.getMessage()}"
                  currentBuild.result = 'FAILURE'
                  error "Failed to deploy deployment file for ${image.name}"
                }
              }
            }
            sh "git add ./yml-Files/kustomization.yml"
            sh "git commit -m 'jenkins push'"
            try {
              sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Brights-DevOps-2022-Script/DevOps-Daemons.git HEAD:main"
            } catch (Exception e) {
              println "Error pushing deployment file: ${e.getMessage()}"
              currentBuild.result = 'FAILURE'
              error "Failed to push deployment file"
            }
          }
        }
      }
      }
    
}
}