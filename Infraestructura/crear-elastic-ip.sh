#!/bin/bash
set -x

# Deshabilitamos paginación de salida los comandos CLI:
# Referencia: https://docs.aws.amazon.com/es_es/cli/latest/userguide/cliv2-migration.html#cliv2-migration-output-pager
export AWS_PAGER=""

# Configuramos el nombre de la instancia a la que le vamos a asignar la IP elástica
INSTANCE_NAME=practica-1

# Obtenemos el Id de la instancia a partir de su nombre
INSTANCE_ID=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
                      "Name=instance-state-name,Values=running" \
            --query "Reservations[*].Instances[*].InstanceId" \
            --output text)

# Creamos una IP elástica
ELASTIC_IP=$(aws ec2 allocate-address --query PublicIp --output text)

# Asociamos la IP elástica a la instancia de la practica 1
aws ec2 associate-address --instance-id $INSTANCE_ID --public-ip $ELASTIC_IP