# OHSDI on Hadoop

This repo contains documentation for getting started with running [OHDSI](https://github.com/OHDSI)
projects on Hadoop by using Docker containers to run everything on one machine.

## 1. Download the Common Data Model OMOP data.

This downloads the vocab and synpuf 1k datasets locally.

```bash
./download_data.sh
```

## 2. Run Impala

```bash
docker-compose up -d
```

When Impala has started the web UI will be visible by running:

```bash
open http://$(docker-machine ip):25000
```

## 3. Import Common Data Model data

```bash
docker cp import_cdm.sh $(docker-compose ps -q impala):/import_cdm.sh
docker-compose exec impala ./import_cdm.sh
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

