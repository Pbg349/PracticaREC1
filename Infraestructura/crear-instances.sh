#!/bin/bash
set -x

# Deshabilitamos paginación de salida los comandos CLI:
# Referencia: https://docs.aws.amazon.com/es_es/cli/latest/userguide/cliv2-migration.html#cliv2-migration-output-pager
export AWS_PAGER=""

# Variables de configuración
AMI_ID=ami-003e0d3cea6ba283a
COUNT=1
INSTANCE_TYPE=t2.micro
KEY_NAME=RECUPERACION
INSTANCE_NAME_PRACTICA1=practica-1
SECURITY_GROUP_PRACTICA1=gs-practica-1


# Creamos una instancia EC2 para el equipo

aws ec2 run-instances \
    --image-id $AMI_ID \
    --count $COUNT \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-groups $SECURITY_GROUP_PRACTICA1 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME_PRACTICA1}]"