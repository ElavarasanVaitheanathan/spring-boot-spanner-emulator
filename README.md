# Spring Boot Spanner Emulator Docker Setup

This project demonstrates a complete multi-container Docker setup for running a **Spring Boot application** with **Google Cloud Spanner Emulator**.

## Architecture

The setup consists of 3 Docker containers:

1. **Spanner Emulator** - Google Cloud Spanner local emulator
2. **Spanner Init** - Initializes database schema and sample data
3. **Spring Boot App** - REST API application

## Prerequisites

- Docker Desktop installed and running
- Docker Compose installed
- Maven (for building the Spring Boot app)
- Java 21+ (or Microsoft OpenJDK 25 LTS)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/ElavarasanVaitheanathan/spring-boot-spanner-emulator.git
cd spring-boot-spanner-emulator
```

### 2. Build the Spring Boot Application

```bash
mvn clean package -DskipTests
```

This creates `target/spring-boot-spanner-app-1.0.0.jar`

### 3. Start All Containers

```bash
docker-compose up --build
```

The containers will start in this order:
- `spanner-emulator` (waits for health check)
- `spanner-init` (waits for emulator, initializes schema)
- `spring-boot-app` (waits for init completion)

### 4. Verify the Application

Once all containers are running, test the endpoints:

```bash
# Health check
curl http://localhost:8080/health

# Welcome endpoint
curl http://localhost:8080/

# Get all users
curl http://localhost:8080/users

# Get all products
curl http://localhost:8080/products

# Create a new user
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user-004",
    "firstName": "Alice",
    "lastName": "Williams",
    "email": "alice@example.com",
    "createdAt": "2024-01-01T10:00:00"
  }'

# Create a new product
curl -X POST http://localhost:8080/products \
  -H "Content-Type: application/json" \
  -d '{
    "productId": "prod-004",
    "productName": "Monitor",
    "description": "4K Monitor",
    "price": 499.99,
    "stockQuantity": 75,
    "createdAt": "2024-01-01T10:00:00"
  }'
```

## Project Structure

```
.
├── docker-compose.yml          # Multi-container orchestration
├── Dockerfile                  # Spring Boot app container
├── pom.xml                     # Maven configuration
├── init-scripts/
│   └── init-spanner.sh         # Schema and data initialization
└── src/main/
    ├── java/com/example/
    │   ├── Application.java    # Spring Boot entry point
    │   ├── model/
    │   │   ├── User.java       # User entity
    │   │   └── Product.java    # Product entity
    │   ├── repository/
    │   │   ├── UserRepository.java
    │   │   └── ProductRepository.java
    │   └── controller/
    │       └── HealthController.java
    └── resources/
        └── application.properties # Spring configuration
```

## Configuration

### Environment Variables

All configuration is passed via environment variables in `docker-compose.yml`:

- `SPANNER_EMULATOR_HOST` - Spanner emulator address (default: `localhost:9010`)
- `SPRING_CLOUD_GCP_SPANNER_INSTANCE_ID` - Spanner instance name
- `SPRING_CLOUD_GCP_SPANNER_DATABASE` - Database name
- `SPRING_CLOUD_GCP_PROJECT_ID` - GCP project ID (for emulator, can be anything)

### Database Schema

**Users Table:**
```sql
CREATE TABLE Users (
    user_id STRING(36) NOT NULL,
    first_name STRING(255),
    last_name STRING(255),
    email STRING(255),
    created_at TIMESTAMP,
    PRIMARY KEY (user_id)
);
```

**Products Table:**
```sql
CREATE TABLE Products (
    product_id STRING(36) NOT NULL,
    product_name STRING(255),
    description STRING(1024),
    price NUMERIC,
    stock_quantity INT64,
    created_at TIMESTAMP,
    PRIMARY KEY (product_id)
);
```

## Common Commands

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f spring-boot-app
docker-compose logs -f spanner-emulator
docker-compose logs -f spanner-init
```

### Stop Containers

```bash
docker-compose down
```

### Clean Up Everything

```bash
docker-compose down -v  # Remove volumes too
```

### Rebuild Containers

```bash
docker-compose build --no-cache
docker-compose up
```

## Troubleshooting

### Container won't start

1. Check logs:
   ```bash
   docker-compose logs spanner-init
   ```

2. Ensure JAR is built:
   ```bash
   mvn clean package -DskipTests
   ```

### Cannot connect to Spanner

1. Verify emulator is running:
   ```bash
   docker ps | grep spanner-emulator
   ```

2. Check environment variables match in `docker-compose.yml`

### Port conflicts

If ports 8080, 9010, or 9020 are in use:

1. Modify `docker-compose.yml` port mappings
2. Or stop conflicting services:
   ```bash
   # Find process using port 8080
   lsof -i :8080
   ```

## Compatibility

- **Java**: OpenJDK 21+, Microsoft OpenJDK 25 LTS ✅
- **Spring Boot**: 3.3.4+
- **Maven**: 3.9+
- **Docker**: 20.10+
- **Docker Compose**: 2.0+

## Useful Links

- [Google Cloud Spanner Emulator Documentation](https://cloud.google.com/spanner/docs/emulator)
- [Spring Cloud GCP Spanner](https://cloud.spring.io/spring-cloud-gcp/reference/html/#spring-data-cloud-spanner)
- [Cloud Spanner SQL Reference](https://cloud.google.com/spanner/docs/query-syntax)

## License

MIT
