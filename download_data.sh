#!/usr/bin/env bash

if [[ -e cdmv5vocab ]]; then
  echo "Directory cdmv5vocab exists, skipping download"
else
  curl https://storage.googleapis.com/gatk-demo-tom/vocab_download_v5_%7B1BAA3847-6321-620C-1FFC-B7050B267379%7D.zip > vocab_download_v5.zip
  unzip -d cdmv5vocab vocab_download_v5.zip
  rm vocab_download_v5.zip
fi

if [[ -e synpuf ]]; then
  echo "Directory synpuf exists, skipping download"
else
  curl https://storage.googleapis.com/gatk-demo-tom/cms-synpuf-1000-cdmv5-version-1-0-3.zip > cms-synpuf-1000-cdmv5-version-1-0-3.zip
  unzip -d synpuf cms-synpuf-1000-cdmv5-version-1-0-3.zip
  rm cms-synpuf-1000-cdmv5-version-1-0-3.zip
fi