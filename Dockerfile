FROM maven:3.9.9-jdk-17-slim AS builder
WORKDIR /workspace

COPY pom.xml .
COPY src ./src
COPY web ./web

RUN mvn -q clean package -DskipTests

FROM tomcat:9.0-jdk17-temurin
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

ENV DB_URL=jdbc:mysql://localhost:3306/eappointment?useSSL=false&serverTimezone=Asia/Kuala_Lumpur
ENV DB_USER=root
ENV DB_PASS=

ENV SMTP_HOST=smtp.gmail.com
ENV SMTP_PORT=587
ENV SMTP_USER=eappointmentfskm@gmail.com
ENV SMTP_PASS=
ENV SMTP_FROM_NAME="E-Appointment FSKM"

COPY --from=builder /workspace/target/e-appointment-fskm.war $CATALINA_HOME/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
