#!/usr/bin/env groovy

def imageName = "alex202/brigade-smackweb"

def gitCommit = null
def gitBranch = null
def imageTag = null
def buildDate = null

podTemplate(label: 'mypod', containers: [
    containerTemplate(name: 'golang', image: 'golang:1.8', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.0', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:latest', command: 'cat', ttyEnabled: true)
  ],
  envVars: [

  ],
  volumes: [
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
  ]) {

    node('mypod') {

        checkout scm

        // print environment variables
        echo sh(script: 'env|sort', returnStdout: true)

        sh "git rev-parse --short HEAD > .git/commit-id"
        gitCommit = readFile('.git/commit-id').trim()

        // git branch name is taken from an env var for multi-branch pipeline project, or from git for other projects
        if (env['BRANCH_NAME']) {
            gitBranch = BRANCH_NAME
        } else {
            sh "git rev-parse --abbrev-ref HEAD > .git/branch-name"
            gitBranch = readFile('.git/branch-name').trim()

        }

        imageTag = "${gitBranch}-${gitCommit}"

        sh "date +'%Y-%m-%d %H-%M-%S' > .git/build-date"
        buildDate = readFile('.git/build-date').trim()


        def buildInfo = """# Build info
BUILD_NUMBER=${env.BUILD_NUMBER}
BUILD_DATE=${buildDate}
BUILD_GIT_COMMIT=${gitCommit}
BUILD_GIT_BRANCH=${gitBranch}
DOCKER_IMAGE_TAG=${imageTag}
"""

        echo buildInfo

        stage('Build go binaries') {
            container('golang') {

                def pwd = pwd()

                sh """
                    mkdir -p /go/src/github.com
                    ln -s $pwd /go/src/github.com
                    cd /go/src/github.com/smackweb
                    go get && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o target/smackweb
                """
            }
        }

        stage('Build and push docker image') {
            container('docker') {

                withCredentials([[$class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKER_HUB_USER',
                        passwordVariable: 'DOCKER_HUB_PASSWORD']]) {

                    sh """
                      docker build --force-rm \
                            --build-arg BUILD_DATE="${buildDate}" \
                            --build-arg IMAGE_TAG_REF=${imageTag} \
                            --build-arg VCS_REF=${gitCommit} \
                            -t ${imageName}:${imageTag} .
                      """
                    sh "docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD} "
                    sh "docker push ${imageName}:${imageTag} "
                }
            }
        }

        stage('do some kubectl work') {
            container('kubectl') {

                sh "kubectl get nodes --all-namespaces"
            }
        }
        stage('do some helm work') {
            container('helm') {

                dir("charts") {

                    sh "ls -la"

                    sh "helm lint smackweb"
                    sh """
                        helm upgrade -i smackweb \
                            --set api.host=smackapi-smackapi --set api.port=80 \
                            --set service.type=LoadBalancer --set service.externalPort=80 \
                            --set image.tag=${imageTag}  ./smackweb
                     """

                    sh "helm ls"
                }
            }
        }
    }
}