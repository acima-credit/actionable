pipeline {
  agent { label 'docker' }
  environment {
    SERVICE              = "actionable"
    SLACK_CHANNEL        = "#funding_fathers_n"
  }

  stages {
    stage('build') {
      environment {
        PUBLIC = credentials('acimabot_public_key')
        PRIVATE = credentials('acimabot_private_key')
      }
      steps {
        script {
          try {
            checkout scm
            sh '''
              docker build -f ./Dockerfile.ci -t $SERVICE --build-arg PRIVATE="$PRIVATE" --build-arg PUBLIC="$PUBLIC" .
            '''
          } catch (exc) {
            echo "EXCEPTION: ${exc}"
            throw exc
          } finally {
          }
        }
      }
    }
    stage('test') {
      steps {
        checkout scm
        ansiColor('xterm') {
          sh '''
            docker-compose -f docker-compose.ci.yml up -d
            sleep 5
            docker-compose -f docker-compose.ci.yml run web rake spec
            docker-compose -f docker-compose.ci.yml run web rake rubocop
          '''
        }
      }
    }
  }
  post {
    failure {
      // alert of any failures--master or topic branches
      slackSend channel: "$SLACK_CHANNEL", color: 'danger', message: "<$RUN_DISPLAY_URL|Build $BUILD_NUMBER> on ${env.JOB_NAME.replace('%2F', '/')} failed! (<$RUN_CHANGES_DISPLAY_URL|Changes>)"
    }
    success {
      script {
        if (env.BRANCH_NAME == 'master') {
          slackSend channel: "$SLACK_CHANNEL", color: 'good', message: "<$RUN_DISPLAY_URL|Build $BUILD_NUMBER> on ${env.JOB_NAME.replace('%2F', '/')} passed. (<$RUN_CHANGES_DISPLAY_URL|Changes>)"
        } else {
            // do nothing if a topic branch succeeds
        }
      }
    }
  }
}