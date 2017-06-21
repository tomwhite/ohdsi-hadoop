# OHSDI on Hadoop

This repo contains documentation for getting started with running [OHDSI](https://github.com/OHDSI)
projects on Hadoop.

## 1. Run Impala

It's useful to have an Impala database for development and testing. This section shows 
the simplest way to get one running in the cloud.

_Note that if you have a powerful
laptop with lots of RAM and disk then you can run the docker commands there, rather than
in the cloud._

### Run on a "container-optimized VM"

We'll use EC2, in particular a container-optimized AMI from [here](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html).

Choose the m4.2xlarge instance type.
Increase root partition storage to 30GB.

You can do the same thing on [Google Cloud](http://searchdatascience.com/how-i-got-cloudera-quickstart-vm-running-on-google-compute-engine/).

#### Connect to the instance

And test docker is working:

```bash
ssh -i /path/to/my.pem ec2-user@<private-ip>
docker run hello-world
```

#### Increase Docker root partition limit

This is needed since the Quickstart VM uses the root partition, which is limited to 10GB.

```bash
sudo vi /etc/sysconfig/docker
# edit to make the options line look like this:
# OPTIONS="--default-ulimit nofile=1024:4096 --storage-opt dm.basesize=20G"
sudo service docker restart
docker run hello-world
```

#### Start Cloudera Quickstart VM in a Docker container

The Cloudera Quickstart VM starts the CDH services (including Spark and others). It is
available as a [Docker container](https://www.cloudera.com/documentation/enterprise/5-10-x/topics/quickstart_docker_container.html).

```bash
docker run --name quickstart --hostname=quickstart.cloudera --privileged=true -t -i -d -p 8888 cloudera/quickstart /usr/bin/docker-quickstart
docker logs -f quickstart
```

## 2. Import Common Data Model data

```bash
docker cp import_cdm.sh quickstart:/import_cdm.sh
docker exec -it quickstart ./import_cdm.sh
```