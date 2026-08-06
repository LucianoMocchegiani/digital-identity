#!/bin/sh
set -e

if [ -z "${POSTGRES_MULTIPLE_DATABASES}" ]; then
  echo "No extra databases requested."
  exit 0
fi

echo "Creating databases: ${POSTGRES_MULTIPLE_DATABASES}"

for db in $(echo "${POSTGRES_MULTIPLE_DATABASES}" | tr ',' ' '); do
  exists="$(psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "postgres" -tAc "SELECT 1 FROM pg_database WHERE datname='${db}'")"
  if [ "$exists" = "1" ]; then
    echo "Database already exists: ${db}"
  else
    echo "Creating database: ${db}"
    psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "postgres" -c "CREATE DATABASE \"${db}\";"
  fi
done
