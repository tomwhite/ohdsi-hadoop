#!/usr/bin/env bash

# Based on https://github.com/OHDSI/CommonDataModel/tree/master/Impala

HADOOP_USER=root

set -e
set -x

# 0. Install tools and scripts
#sudo apt-get update
#sudo apt-get install git unzip -y
git clone https://github.com/OHDSI/CommonDataModel
cd CommonDataModel/Impala

# 1. Create an empty schema.
impala-shell -q 'CREATE DATABASE omop_cdm'

# 2. Execute the script OMOP_CDM_ddl_Impala.sql to create the tables and fields.
impala-shell -d omop_cdm -f OMOP_CDM_ddl_Impala.sql

# 3. Load your data into the schema.
curl https://storage.googleapis.com/gatk-demo-tom/vocab_download_v5_%7B1BAA3847-6321-620C-1FFC-B7050B267379%7D.zip > vocab_download_v5.zip
unzip -d cdmv5vocab vocab_download_v5.zip
hdfs dfsadmin -safemode wait
hadoop fs -put cdmv5vocab cdmv5vocab
hadoop fs -chmod +w cdmv5vocab
impala-shell -d omop_cdm -f VocabImport/OMOP_CDM_vocabulary_load_Impala.sql --var=OMOP_VOCAB_PATH=/user/$HADOOP_USER/cdmv5vocab

curl https://storage.googleapis.com/gatk-demo-tom/cms-synpuf-1000-cdmv5-version-1-0-3.zip > cms-synpuf-1000-cdmv5-version-1-0-3.zip
unzip -d synpuf cms-synpuf-1000-cdmv5-version-1-0-3.zip
hadoop fs -put synpuf synpuf
hadoop fs -chmod +w synpuf
impala-shell -d omop_cdm -f DataImport/OMOP_CDM_synpuf_load_Impala.sql --var=OMOP_SYNPUF_PATH=/user/$HADOOP_USER/synpuf

# 4. Convert to Parquet format.
impala-shell -q 'CREATE DATABASE omop_cdm_parquet'
impala-shell -f OMOP_Parquet.sql

# 5. Run simple queries to sanity check.
impala-shell -d omop_cdm_parquet -q 'SELECT COUNT(1) FROM concept'
impala-shell -d omop_cdm_parquet -q 'SELECT COUNT(1) FROM person'