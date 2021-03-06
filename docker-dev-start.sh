#!/bin/bash

[ -z "$AWS_SECRET_ACCESS_KEY" ] && {
  echo "Env var AWS_SECRET_ACCESS_KEY is not defined; export it!"
  exit 1
}

[ -z "$AWS_ACCESS_KEY_ID" ] && {
  echo "Env var AWS_ACCESS_KEY_ID is not defined; export it!"
  exit 1
}

[ -z "$EC2_REGION" ] && {
  echo "Env var EC2_REGION is not defined; export it!"
  exit 1
}

cp -p prometheus/prometheus.yml{.tmpl,}
ansible/ec2.py |./get-ec2-ips4prom.py >> prometheus/prometheus.yml

cat << EOF >> prometheus/prometheus.yml

  - job_name: 'ec2'
    scrape_interval: 5s
    ec2_sd_configs:
      - region: $EC2_REGION
        access_key: $AWS_ACCESS_KEY_ID
        secret_key: "$AWS_SECRET_ACCESS_KEY"
        port: 9100
    relabel_configs:
      - source_labels: [__meta_ec2_public_ip]
        replacement: \${1}:9100
        target_label: __address__
EOF

[ ! -d prometheus-data ] && mkdir prometheus-data

docker-compose up -d
