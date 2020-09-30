FROM maven:3.6.3-jdk-11 AS maven
COPY . .
RUN mvn clean install
WORKDIR /target

FROM openjdk:11-alpine
COPY --from=maven testDeploiement-1.0.0.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]

