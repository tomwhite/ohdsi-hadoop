# OHSDI on Hadoop

This repo contains documentation for getting started with running [OHDSI](https://github.com/OHDSI)
projects on Hadoop.

## 1. Run Impala

It's useful to have an Impala database for development and testing. This section shows 
the simplest way to get one running in the cloud.

_Note that if you have a powerful
laptop with lots of RAM and disk then you can run the docker commands there, rather than
in the cloud._

### Launch a cloud instance

We'll use [Google Cloud](https://cloud.google.com/compute/docs/containers/container_vms), with the following command:

```bash
gcloud compute --project "gcp-director" \
instances create "quickstart-instance-1" \
--image container-vm --zone "us-east4-a" \
--machine-type "n1-standard-8" \
--boot-disk-size=30GB
```

#### Connect to the instance

Connect and test docker is working:

```bash
ssh -i /path/to/my.pem ec2-user@<public-ip>
docker run hello-world
```

#### Start Cloudera Quickstart VM in a Docker container

The Cloudera Quickstart VM starts the CDH services (including Spark and others). It is
available as a [Docker container](https://www.cloudera.com/documentation/enterprise/5-10-x/topics/quickstart_docker_container.html).

```bash
sudo docker run --name quickstart --hostname=quickstart.cloudera --privileged=true -t -i 
-d -p 8888:8888 -p 7180:7180 cloudera/quickstart /usr/bin/docker-quickstart
sudo docker logs -f quickstart
```

Wait until you see the Impala daemons have been started.

Some troubleshooting commands that may be useful:

```bash
sudo docker exec -it quickstart bash
netstat -na | grep -e '\(9000\|50010\|50020\|50070\|50075\|21000\|21050\|25000\|25010\|25020\)'
less /var/log/impala/impalad.INFO
```

## 2. Import Common Data Model data

Clone this repository so you can run the script to import CDM data.

```bash
git clone https://github.com/tomwhite/ohdsi-hadoop.git
```

Then carry out the import:

```bash
sudo docker cp ohdsi-hadoop/import_cdm.sh quickstart:/import_cdm.sh
sudo docker exec -it quickstart ./import_cdm.sh
```