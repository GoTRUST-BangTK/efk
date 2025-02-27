#!/bin/bash

NATIVE_FILE=$CONFIG_DIR/elasticsearch.keystore

create_keystore() {
  printf "========== Creating Elasticsearch Keystore ==========\n"
  # Remove current Keystore
  if [ -f "$NATIVE_FILE" ]; then
      echo "Remove old elasticsearch.keystore"
      rm $NATIVE_FILE
  fi

  elasticsearch-keystore create >>/dev/null

  # Setting Bootstrap Password
  echo "Setting bootstrap password..."
  (echo "$ELASTIC_PASSWORD" | elasticsearch-keystore add -x 'bootstrap.password')

  # setup_passwords
  echo "Saving new elasticsearch.keystore"
  chmod 0644 $NATIVE_FILE
}

config_s3(){
  printf "\n========== Config S3 Keys ==========\n"
  if [[ -n "$S3_ACCESS_KEY" && -n "$S3_SECRET_KEY" ]]; then
    echo "$S3_ACCESS_KEY" | /opt/bitnami/elasticsearch/bin/elasticsearch-keystore add -x s3.client.default.access_key --force
    echo "$S3_SECRET_KEY" | /opt/bitnami/elasticsearch/bin/elasticsearch-keystore add -x s3.client.default.secret_key --force
  fi
}

create_keystore
config_s3
chown 1001:1001 /opt/bitnami/elasticsearch -R

