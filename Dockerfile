# ---------- Runtime ----------
FROM quay.io/wildfly/wildfly:latest-jdk17

# Copy already-built WAR from GitHub Actions artifact
COPY target/*.war /opt/jboss/wildfly/standalone/deployments/

# Switch temporarily to root to set file ownership
USER root
RUN chown jboss:jboss /opt/jboss/wildfly/standalone/deployments/*.war

# Run as jboss user
USER jboss

EXPOSE 8080
EXPOSE 9990
EXPOSE 8443
