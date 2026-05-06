# ---------- STAGE 1: Build with Maven ----------
FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy only Maven descriptors first (cache dependencies)
COPY pom.xml .
# If you have a settings.xml for repo auth, copy it too:
# COPY settings.xml /root/.m2/settings.xml

# Download dependencies (cacheable)
RUN mvn -B dependency:go-offline -DskipTests

# Copy source code and build
COPY src ./src
RUN mvn -B clean package -DskipTests

# ---------- STAGE 2: JBoss EAP 8 runtime ----------
FROM quay.io/wildfly/wildfly:latest-jdk17 AS run
# or: FROM registry.redhat.io/jboss-eap-8/eap72-openjdk11:latest
# choose the EAP 8 image tag you need from your registry and subscription

# Deploy WAR/EAR from build stage
COPY --from=build /app/target/*.war /opt/jboss/wildfly/standalone/deployments/

# Switch temporarily to root to set file ownership
USER root
RUN chown jboss:jboss /opt/jboss/*

# Optional: set user/group (as image expectation)
USER jboss

EXPOSE 8080
EXPOSE 9990
EXPOSE 8443

