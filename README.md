# OHSDI on Hadoop

This repo contains documentation for getting started with running [OHDSI](https://github.com/OHDSI)
projects on Hadoop by using Docker containers to run everything on one machine.

## 1. Download the Common Data Model OMOP data.

This downloads the vocab and synpuf 1k datasets locally.

```bash
./download_data.sh
```

## 2. Run Impala

Checkout a local copy of [docker-impala](https://github.com/tomwhite/docker-impala) so we can run Impala in a Docker container:


```bash
git clone https://github.com/tomwhite/docker-impala
docker-compose up -d
```

When Impala has started the web UI will be visible by running:

```bash
open http://$(docker-machine ip):25000
```

(Note that for troubleshooting purposes you can connect to the container with `docker-compose exec impala bash`, then check _/tmp/supervisord.log_ and the log files in _/var/log/hadoop-hdfs_, _/var/log/hive_, and _/var/log/impala_.)

## 3. Import Common Data Model data

```bash
docker cp import_cdm.sh $(docker-compose ps -q impala):/import_cdm.sh
docker-compose exec impala ./import_cdm.sh
```

## 4. Run Achilles

First create an `achilles` database in Impala.

```bash
docker-compose exec impala impala-shell -q 'CREATE DATABASE achilles'
```

Next checkout a local copy of Achilles so we can build the Docker container:

```bash
git clone https://github.com/tomwhite/Achilles
(cd Achilles; git checkout impala-fixes)
docker build -t achilles Achilles
```

Now run Achilles to load the data into the `achilles` database in Impala.

```bash
docker run \
  --rm \
  --net=host \
  -v "$(pwd)"/output:/opt/app/output \
  -v "$(pwd)"/impala-drivers/:/impala-drivers \
  -e ACHILLES_SOURCE=Impala \
  -e ACHILLES_DB_URI=impala://$(docker-machine ip)/omop_cdm_parquet \
  -e ACHILLES_CDM_SCHEMA=omop_cdm_parquet \
  -e ACHILLES_VOCAB_SCHEMA=omop_cdm_parquet \
  -e ACHILLES_RES_SCHEMA=achilles \
  -e ACHILLES_CDM_VERSION=5 \
  -e ACHILLES_PATH_TO_DRIVER=/impala-drivers/Cloudera_ImpalaJDBC4_2.5.36 \
  achilles
```

(Based on [https://github.com/OHDSI/Achilles/blob/master/README-impala.md](https://github.com/OHDSI/Achilles/blob/master/README-impala.md).)

## 5. Run ATLAS

Checkout a local copy of Broadsea so we can build the Docker container:

```bash
git clone https://github.com/tomwhite/Broadsea
(cd Broadsea; git checkout impala-fixes)
```

Creating missing tables in Impala:

```bash
docker cp Broadsea/impala/multiple_datasets.sql $(docker-compose ps -q impala):/multiple_datasets.sql
docker-compose exec impala impala-shell -f multiple_datasets.sql
```

Create the `ohdsi` database in PostgreSQL:

```bash
docker cp Broadsea/impala/create_postgres_db.sql $(docker-compose ps -q postgres):/create_postgres_db.sql
docker-compose exec postgres /bin/sh -c "su - -c 'psql -f /create_postgres_db.sql' postgres"
```

Start the services and allow the database to be migrated

```bash
docker-compose -f Broadsea/impala/docker-compose.yml up -d
# Wait a minute or so
docker-compose -f Broadsea/impala/docker-compose.yml down
```

Update the source daimons to point to Impala.

```bash
docker cp Broadsea/impala/source_source_daimon.sql $(docker-compose ps -q postgres):/source_source_daimon.sql
docker-compose exec postgres /bin/sh -c "su - -c 'psql -f /source_source_daimon.sql -d ohdsi' postgres"
```

Start the services up again.

```bash
docker-compose -f Broadsea/impala/docker-compose.yml up -d
```

Visit the ATLAS web UI:

```bash
open http://$(docker-machine ip):8080/atlas
```

(Based on [https://github.com/OHDSI/Broadsea/tree/master/impala](https://github.com/OHDSI/Broadsea/tree/master/impala).)

## 6. Shutdown

```bash
docker-compose -f Broadsea/impala/docker-compose.yml down
docker-compose down
```

## (Optional) Running Docker on Google Cloud

_Note that if you have a powerful
laptop with lots of RAM and disk then you can run the docker commands there, rather than
in the cloud._

We'll use [Google Cloud](https://cloud.google.com/compute/docs/containers/container_vms), with the following command:

```bash
gcloud compute --project "gcp-director" \
instances create "quickstart-instance-1" \
--image container-vm --zone "us-east4-a" \
--machine-type "n1-standard-8" \
--boot-disk-size=30GB
```

### Connect to the instance

Connect and test docker is working:

```bash
ssh -i /path/to/my.pem ec2-user@<public-ip>
docker run hello-world
```

