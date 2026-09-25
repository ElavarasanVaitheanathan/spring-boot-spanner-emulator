FROM eclipse-temurin:25-jdk-alpine

WORKDIR /app

# Copy the built JAR from Maven
COPY target/spring-boot-spanner-app-1.0.0.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
