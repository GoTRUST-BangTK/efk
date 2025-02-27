#!/bin/bash

# Tạo chứng chỉ CA
echo "Create Ca certificate"
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca-cert.pem -subj "/CN=Fluentd-CA"

# Tạo chứng chỉ và khóa cho Fluentd
echo "Create Fluentd certificate"
openssl genrsa -out fluentd.key 2048
openssl req -new -key fluentd.key -out fluentd.csr -subj "/CN=fluentd-server"
openssl x509 -req -in fluentd.csr -CA ca-cert.pem -CAkey ca.key -CAcreateserial -out fluentd.crt -days 365 -sha256

# Tạo chứng chỉ và khóa cho Fluentbit
echo "Create Fluent_bit certificate"
openssl genrsa -out fluentbit.key 2048
openssl req -new -key fluentbit.key -out fluentbit.csr -subj "/CN=fluentbit-client"
openssl x509 -req -in fluentbit.csr -CA ca-cert.pem -CAkey ca.key -CAcreateserial -out fluentbit.crt -days 365 -sha256

# Cung cấp đường dẫn cho các chứng chỉ và khóa
# echo "Chứng chỉ và khóa đã được tạo:" 
# openssl s_client -connect 172.22.163.223:24224 -CAfile  ca-cert.pem