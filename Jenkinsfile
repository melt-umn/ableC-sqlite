#!groovy

/* Set the properties this job has.
   I think there's a bug where the very first run lacks these... */
properties([
  /* Set our config to take a parameter when a build is triggered.
     We should always have defaults, I don't know what happens when
     it's triggered by a commit without a default... */
  [ $class: 'ParametersDefinitionProperty',
    parameterDefinitions: [
      [ $class: 'StringParameterDefinition',
        name: 'SILVER_BASE',
        defaultValue: '/export/scratch/melt-jenkins/custom-silver/',
        description: 'Silver installation path to use. Currently assumes only one build machine. Otherwise a path is not sufficient, we need to copy artifacts or something else.'
      ],
      [ $class: 'StringParameterDefinition',
        name: 'ABLEC_BASE',
        defaultValue: 'ableC',
        description: 'AbleC installation path to use.'
      ]
    ]
  ],
  /* If we don't set this, everything is preserved forever.
     We don't bother discarding build logs (because they're small),
     but if this job keeps artifacts, we ask them to only stick around
     for awhile. */
  [ $class: 'BuildDiscarderProperty',
    strategy:
      [ $class: 'LogRotator',
        artifactDaysToKeepStr: '120',
        artifactNumToKeepStr: '20'
      ]
  ]
])

/* If the above syntax confuses you, be sure you've skimmed through
   https://github.com/jenkinsci/pipeline-plugin/blob/master/TUTORIAL.md

   In particular, Jenkins has this thing that turns a map with a '$class' property
   into an actual object of that type, with the remainder of the map being its
   parameters. */


/* stages are pretty much just labels about what's going on */

stage ("Build") {

  /* a node allocates an executor to actually do work */
  node {
    checkout([ $class: 'GitSCM',
               branches: [[name: '*/develop']],
               doGenerateSubmoduleConfigurations: false,
               extensions: [
                 [ $class: 'RelativeTargetDirectory',
                   relativeTargetDir: 'ableC']
               ],
               submoduleCfg: [],
               userRemoteConfigs: [
                 [url: 'https://github.com/melt-umn/ableC.git']
               ]
             ])
    checkout([ $class: 'GitSCM',
               branches: [[name: '*/master']],
               doGenerateSubmoduleConfigurations: false,
               extensions: [
                 [ $class: 'RelativeTargetDirectory',
                   relativeTargetDir: "edu.umn.cs.melt.exts.ableC.sqlite"]
               ],
               submoduleCfg: [],
               userRemoteConfigs: [
                 [url: 'https://github.com/melt-umn/edu.umn.cs.melt.exts.ableC.sqlite.git']
               ]
             ])

    /* env.PATH is the master's path, not the executor's */
    withEnv(["PATH=${SILVER_BASE}/support/bin/:${env.PATH}"]) {
      dir("edu.umn.cs.melt.exts.ableC.sqlite/artifact") {
        sh "./build.sh -I ${ABLEC_BASE}"
      }
    }
  }

}

stage ("Modular Analyses") {
  node {
    withEnv(["PATH=${SILVER_BASE}/support/bin/:${env.PATH}"]) {
      def mdir = "edu.umn.cs.melt.exts.ableC.sqlite/modular_analyses"
      dir("${mdir}/determinism") {
        sh "./run.sh -I ${ABLEC_BASE}"
      }
      dir("${mdir}/well_definedness") {
        sh "./run.sh -I ${ABLEC_BASE}"
      }
    }
  }
}

stage ("Test") {
  node {
    def top_dir = "edu.umn.cs.melt.exts.ableC.sqlite"
    dir("${top_dir}/test/positive") {
      sh "./the_tests.sh"
    }
    dir("${top_dir}/test/negative") {
      sh "./the_tests.sh"
    }
  }
}

