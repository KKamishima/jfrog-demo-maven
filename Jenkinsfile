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
                    serverId: 'mnckk2',
                    releaseRepo: 'mvn-virtual',
                    snapshotRepo: 'mvn-virtual'
                )  
                rtMavenDeployer (
                    id: 'maven-deployer',
                    serverId: 'mnckk2',
                    releaseRepo: 'mvn-virtual',
                    snapshotRepo: 'mvn-virtual',
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
                   captureEnv: true
                )
                // Run Maven on a Unix agent.
                // sh "mvn -Dmaven.test.failure.ignore=true clean war:war"
                rtMavenRun (
                    // Tool name from Jenkins configuration.
                    tool: "maven-3.6.3",
                    pom: 'pom.xml',
                    //goals: 'clean war:war',
                    goals: 'clean install -U',
                    // Maven options.
                    opts: '-Xms1024m -Xmx4096m',
                    resolverId: 'maven-resolver',
                    deployerId: 'maven-deployer'
                )
                rtPublishBuildInfo(
                    serverId: 'mnckk2'
                )
            }
        }

        stage ('Xray scan') {
            steps {
                xrayScan (
                    serverId: 'mnckk2'
                )
            }
        }
    }
}
