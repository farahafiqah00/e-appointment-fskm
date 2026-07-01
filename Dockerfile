FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /workspace

COPY pom.xml .
COPY src ./src
COPY web ./web

RUN mvn -q clean package -DskipTests

FROM tomcat:9.0-jdk17-temurin
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

COPY --from=builder /workspace/target/e-appointment-fskm.war $CATALINA_HOME/webapps/ROOT.war

RUN printf '#!/bin/sh\nsed -i "s/port=\\"8080\\"/port=\\"${PORT}\\"/" "$CATALINA_HOME/conf/server.xml"\nexec catalina.sh run\n' > /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
CMD ["/entrypoint.sh"]