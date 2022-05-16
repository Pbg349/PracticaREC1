#!/bin/bash
set -x

# Deshabilitamos paginación de salida los comandos CLI:
# Referencia: https://docs.aws.amazon.com/es_es/cli/latest/userguide/cliv2-migration.html#cliv2-migration-output-pager
export AWS_PAGER=""

# Creamos el grupo de seguridad: gs-practica-1
aws ec2 create-security-group \
    --group-name gs-practica-1 \
    --description "Reglas de practica-1"

# Creamos regla de accesso SSH:
aws ec2 authorize-security-group-ingress \
    --group-name gs-practica-1 \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Creamos regla de accesso HTTP:
aws ec2 authorize-security-group-ingress \
    --group-name gs-practica-1 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Creamos regla de accesso PostgreSQL:
aws ec2 authorize-security-group-ingress \
    --group-name gs-practica-1 \
    --protocol tcp \
    --port 5432 \
    --cidr 0.0.0.0/0

# Creamos regla de accesso HTTPS:
aws ec2 authorize-security-group-ingress \
    --group-name gs-practica-1 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0