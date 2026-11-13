# RETP — Real Estate Tokenization Platform

Laboratorio de diseño e implementación de una plataforma de tokenización de participaciones de una SPV inmobiliaria. La representación ERC-3643 es un espejo técnico auxiliar: no sustituye el régimen societario ni el Libro Registro de Socios.

## Entorno local

La infraestructura ejecutable está definida en [infrastructure/docker](infrastructure/docker/README.md).

Arranque desde la raíz del repositorio:

```bash
cp infrastructure/docker/.env.example infrastructure/docker/.env
# Edita infrastructure/docker/.env y cambia las credenciales locales.
docker compose --env-file infrastructure/docker/.env -f infrastructure/docker/compose.yaml up -d
```

Componentes locales: PostgreSQL, RabbitMQ y Anvil. SoftHSM2 se puede añadir con el perfil `signing-lab`. Consulta la guía de infraestructura para requisitos, conexiones, verificación y parada.

## Documentación

La documentación de arquitectura, dominio y especificación se organiza en `docs/`. Los ficheros de infraestructura en `infrastructure/` son la definición ejecutable del entorno de desarrollo.
