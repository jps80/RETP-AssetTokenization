# RETP — infraestructura local

Esta carpeta define el entorno local reproducible de RETP mediante Docker Compose.

## Componentes

| Componente | Servicio Compose | Uso |
|---|---|---|
| PostgreSQL 16.4 | `postgres` | Persistencia operacional de NestJS/Prisma |
| RabbitMQ 3.13.7 Management | `rabbitmq` | Mensajería y distribución de eventos |
| Anvil (Foundry v1.0.0) | `anvil` | Blockchain EVM local para desarrollo y pruebas |
| SoftHSM2 (Ubuntu 22.04) | `softhsm2` | Token store criptográfico de laboratorio mediante PKCS#11 |

SoftHSM2 se inicia bajo el perfil opcional `signing-lab`. Es una implementación software para laboratorio, no un HSM físico ni una solución de custodia certificada. El servicio de firma RETP es un componente de aplicación independiente y todavía debe integrarse con este token store.

## Requisitos

- Docker Engine con Docker Compose v2.
- Acceso al registro de imágenes GHCR y Docker Hub.
- Puertos locales disponibles: 5433, 5672, 15672 y 8545.

## Preparación

Desde la raíz del repositorio:

```bash
cp infrastructure/docker/.env.example infrastructure/docker/.env
```

El ejemplo configura la base de datos PostgreSQL como `retp-postgres`, el usuario `retp` y una contraseña de desarrollo. Son credenciales públicas y débiles, exclusivamente para desarrollo local; no las uses en entornos compartidos o productivos. Si cambias la contraseña PostgreSQL, actualiza también `DATABASE_URL` de la API.

## Arranque

```bash
docker compose --env-file infrastructure/docker/.env -f infrastructure/docker/compose.yaml up -d
```

Para añadir SoftHSM2:

```bash
docker compose --env-file infrastructure/docker/.env -f infrastructure/docker/compose.yaml --profile signing-lab up -d
```

## Verificación

```bash
docker compose --env-file infrastructure/docker/.env -f infrastructure/docker/compose.yaml ps
docker compose --env-file infrastructure/docker/.env -f infrastructure/docker/compose.yaml logs --tail=100 postgres
docker compose --env-file infrastructure/docker/.env -f infrastructure/docker/compose.yaml exec postgres pg_isready -U retp -d retp-postgres
docker compose --env-file infrastructure/docker/.env -f infrastructure/docker/compose.yaml exec rabbitmq rabbitmq-diagnostics -q ping
```

Anvil expone JSON-RPC en `http://127.0.0.1:8545` y usa chain ID `31337`. Sus cuentas y claves son exclusivamente de desarrollo local; nunca deben reutilizarse.

## Conexiones para aplicaciones ejecutadas en el host

- PostgreSQL RETP: `postgresql://retp:<POSTGRES_PASSWORD>@localhost:5433/retp-postgres?schema=public`
- RabbitMQ: `amqp://retp:<RABBITMQ_DEFAULT_PASS>@localhost:5672`
- Anvil: `http://127.0.0.1:8545`

El contenedor PostgreSQL se llama `retp-postgres-v03`, la base de datos se llama `retp-postgres` y el puerto host `5433` se redirige al puerto interno `5432`. Usa el volumen dedicado `retp_postgres_data`. Esto permite que conviva con una instancia PostgreSQL preexistente que utilice el puerto host `5432`, sin detenerla ni reutilizar sus datos.

Dentro de una red Compose, los hostnames son `postgres`, `rabbitmq` y `anvil`, y los puertos internos son 5432, 5672 y 8545.

## Parada y persistencia

```bash
docker compose --env-file infrastructure/docker/.env -f infrastructure/docker/compose.yaml down
```

Los datos permanecen en volúmenes Docker. Para borrar también los datos persistidos:

```bash
docker compose --env-file infrastructure/docker/.env -f infrastructure/docker/compose.yaml down -v
```

**Advertencia:** `down -v` elimina los volúmenes de PostgreSQL, RabbitMQ y SoftHSM2. No lo ejecutes si necesitas conservar datos, mensajes o claves de laboratorio.

## Límites de esta entrega

- La configuración debe validarse en el equipo local; la actualización de los valores por defecto no implica una nueva ejecución de Docker Compose.
- Las imágenes están fijadas por tag, pero todavía no por digest OCI. La aceptación reproducible exigirá registrar digests.
- No se incluye aún el backend NestJS, el servicio de firma, el despliegue T-REX ni la inicialización de contratos.
- No se configura Sepolia ni se incluyen claves privadas externas.
- Los puertos se publican únicamente en loopback para reducir exposición local.
