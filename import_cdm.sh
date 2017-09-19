#!/usr/bin/env bash

# Based on https://github.com/OHDSI/CommonDataModel/tree/master/Impala

HADOOP_USER=root

set -e
set -x

# 0. Install tools and scripts
yum install -y git
git clone https://github.com/OHDSI/CommonDataModel
cd CommonDataModel/Impala
# Use this (older) version of CommonDataModel (the newer one is not yet compatible with Achilles)
git checkout de8c1d0f234ac2945c921124b36cbfeae2751a48

# 1. Create an empty schema.
impala-shell -q 'CREATE DATABASE omop_cdm'

# 2. Execute the script OMOP_CDM_ddl_Impala.sql to create the tables and fields.
impala-shell -d omop_cdm -f OMOP_CDM_ddl_Impala.sql

# 3. Load your data into the schema.
hdfs dfsadmin -safemode wait
hadoop fs -mkdir .

hadoop fs -put /data/cdmv5vocab cdmv5vocab
hadoop fs -chmod +w cdmv5vocab
impala-shell -d omop_cdm -f VocabImport/OMOP_CDM_vocabulary_load_Impala.sql --var=OMOP_VOCAB_PATH=/user/$HADOOP_USER/cdmv5vocab

hadoop fs -put /data/synpuf synpuf
hadoop fs -chmod +w synpuf
impala-shell -d omop_cdm -f DataImport/OMOP_CDM_synpuf_load_Impala.sql --var=OMOP_SYNPUF_PATH=/user/$HADOOP_USER/synpuf

# 4. Convert to Parquet format.
impala-shell -q 'CREATE DATABASE omop_cdm_parquet'
impala-shell -f OMOP_Parquet.sql
impala-shell -q 'DROP DATABASE omop_cdm CASCADE'

# 5. Run simple queries to sanity check.
impala-shell -d omop_cdm_parquet -q 'SELECT COUNT(1) FROM concept'
impala-shell -d omop_cdm_parquet -q 'SELECT COUNT(1) FROM person'