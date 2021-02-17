pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "maven-3.6.3"
    }

    stages {
        stage('ArtfConfig') {
            steps {
                rtMavenResolver (
                    id: 'maven-resolver',
                    serverId: 'demo5-art',
                    releaseRepo: 'kk-maven-virtual',
                    snapshotRepo: 'kk-maven-virtual'
                )  
                rtMavenDeployer (
                    id: 'maven-deployer',
                    serverId: 'demo5-art',
                    releaseRepo: 'kk-maven-virtual',
                    snapshotRepo: 'kk-maven-virtual',
                    // By default, 3 threads are used to upload the artifacts to Artifactory. You can override this default by setting:
                    threads: 3,
                    // Attach custom properties to the published artifacts:
                    // properties: ['key1=value1', 'key2=value2']
                    deployArtifacts: true,
                    includeEnvVars: true,
                )
            }
        }

        stage('MavenBuild') {
            steps {
                // Get some code from a GitHub repository
                // git branch: 'main', url: 'https://github.com/KKamishima/java-webapp-container.git'

                rtBuildInfo (
                   captureEnv: true,
                    buildName: 'maven-build'
                )
                // Run Maven on a Unix agent.
                // sh "mvn -Dmaven.test.failure.ignore=true clean war:war"
                rtMavenRun (
                    // Tool name from Jenkins configuration.
                    tool: "maven-3.6.3",
                    pom: 'pom.xml',
                    //goals: 'clean war:war',
                    goals: 'clean install',
                    // Maven options.
                    opts: '-Xms1024m -Xmx4096m',
                    resolverId: 'maven-resolver',
                    deployerId: 'maven-deployer',
                    buildName: 'maven-build'
                )
                rtPublishBuildInfo(
                    serverId: 'demo5-art',
                    buildName: 'maven-build'
                )
                // To run Maven on a Windows agent, use
                // bat "mvn -Dmaven.test.failure.ignore=true clean package"
            }

            // post {
            //     // If Maven was able to run the tests, even if some of the test
            //     // failed, record the test results and archive the jar file.
            //     success {
            //         junit '**/target/surefire-reports/TEST-*.xml'
            //         archiveArtifacts 'target/*.jar'
            //     }
            // }
        }
        stage('DockerBuild') {
            steps {
                script {
                    def artf = 'demo5-art.hirofu20.biz'
                    def repo = 'kk-docker-local'
                    def tag = "${artf}/${repo}/java-webapp:${env.BUILD_ID}"
                    def server = Artifactory.server 'demo5-art'
                    def rtDocker = Artifactory.docker server: server

                    def buildInfo = Artifactory.newBuildInfo()
                    buildInfo.name = 'docker-build'
                    buildInfo.env.capture = true

                    docker.build tag
                    rtDocker.push tag, repo, buildInfo
                    server.publishBuildInfo buildInfo
                }
                // rtDockerPush(
                //     serverId: 'demo5-art',
                //     image: "demo5-art.hirofu20.biz/kk-docker-local/java-webapp:${env.BUILD_ID}",
                //     targetRepo: 'kk-docker-local',
                //     // Attach custom properties to the published artifacts:
                //     //properties: 'project-name=docker1;status=stable',
                // )
                // rtPublishBuildInfo(
                //     serverId: 'demo5-art',
                //     buildName: 'docker-build'
                // )
            }
        }

        stage ('Xray scan') {
            steps {
                xrayScan (
                    serverId: 'demo5-art',
                    buildName: 'maven-build',
                    failBuild: true
                )
                xrayScan (
                    serverId: 'demo5-art',
                    buildName: 'docker-build',
                    failBuild: true
                )
            }
        }
    }
}
