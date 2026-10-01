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
if [ ! -d "$target" ]; then
  echo "Falta $target dentro de Jenkins. Montá /opt/majo/site/public en el Compose de Jenkins." >&2
  exit 1
fi
if [ ! -w "$target" ]; then
  echo "Jenkins no puede escribir en $target. Revisá el propietario de /opt/majo/site/public." >&2
  exit 1
fi

for file in privacidad.html booking-config.js logo.jpeg majo.jpeg; do
  cp "$file" "$target/$file"
done
cp index.html "$target/.index.html.new"
mv -f "$target/.index.html.new" "$target/index.html"
echo "Sitio de Majo publicado en $target"
'''
      }
    }
  }
}
