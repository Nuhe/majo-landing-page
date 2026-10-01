pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  triggers {
    pollSCM('H/5 * * * *')
  }

  stages {
    stage('Validate') {
      steps {
        sh '''#!/usr/bin/env bash
set -euo pipefail

for file in index.html privacidad.html booking-config.js logo.jpeg majo.jpeg; do
  test -s "$file"
done
'''
      }
    }

    stage('Deploy') {
      steps {
        sh '''#!/usr/bin/env bash
set -euo pipefail

target=/srv/majo-public
test -d "$target"
test -w "$target"

for file in privacidad.html booking-config.js logo.jpeg majo.jpeg; do
  cp "$file" "$target/$file"
done
cp index.html "$target/.index.html.new"
mv -f "$target/.index.html.new" "$target/index.html"
'''
      }
    }
  }
}
