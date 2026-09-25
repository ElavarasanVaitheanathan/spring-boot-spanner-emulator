#!/bin/bash

set -e

echo "Waiting for Spanner emulator to be ready..."
sleep 10

# Configure gcloud to use the emulator
gcloud config set auth/disable_credentials true
gcloud config set project test-project
gcloud config set api_endpoint_overrides/spanner http://spanner-emulator:9020/

echo "Creating Spanner instance..."
gcloud spanner instances create test-instance \
    --config=emulator-config \
    --description="Test Instance" \
    --nodes=1 || echo "Instance already exists"

echo "Creating Spanner database..."
gcloud spanner databases create test-database \
    --instance=test-instance || echo "Database already exists"

echo "Creating tables..."

# Create Users table
echo "Creating Users table..."
gcloud spanner databases ddl update test-database \
    --instance=test-instance \
    --ddl="CREATE TABLE Users (
        user_id STRING(36) NOT NULL,
        first_name STRING(255),
        last_name STRING(255),
        email STRING(255),
        created_at TIMESTAMP,
        PRIMARY KEY (user_id)
    )" || echo "Users table may already exist"

# Create Products table
echo "Creating Products table..."
gcloud spanner databases ddl update test-database \
    --instance=test-instance \
    --ddl="CREATE TABLE Products (
        product_id STRING(36) NOT NULL,
        product_name STRING(255),
        description STRING(1024),
        price NUMERIC,
        stock_quantity INT64,
        created_at TIMESTAMP,
        PRIMARY KEY (product_id)
    )" || echo "Products table may already exist"

echo "Inserting sample data..."

# Insert sample users
gcloud spanner databases execute-sql test-database \
    --instance=test-instance \
    --sql="INSERT INTO Users (user_id, first_name, last_name, email, created_at) 
           VALUES ('user-001', 'John', 'Doe', 'john@example.com', CURRENT_TIMESTAMP()),
                  ('user-002', 'Jane', 'Smith', 'jane@example.com', CURRENT_TIMESTAMP()),
                  ('user-003', 'Bob', 'Johnson', 'bob@example.com', CURRENT_TIMESTAMP())"

# Insert sample products
gcloud spanner databases execute-sql test-database \
    --instance=test-instance \
    --sql="INSERT INTO Products (product_id, product_name, description, price, stock_quantity, created_at)
           VALUES ('prod-001', 'Laptop', 'High-performance laptop', 1299.99, 50, CURRENT_TIMESTAMP()),
                  ('prod-002', 'Mouse', 'Wireless mouse', 29.99, 200, CURRENT_TIMESTAMP()),
                  ('prod-003', 'Keyboard', 'Mechanical keyboard', 99.99, 150, CURRENT_TIMESTAMP())"

echo "Spanner initialization completed successfully!"
echo "Database: test-database"
echo "Instance: test-instance"
echo "Tables created: Users, Products"
