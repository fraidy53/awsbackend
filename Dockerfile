FROM eclipse-temurin:17-jdk

WORKDIR /app


# 빌드된 JAR 파일과 .env 파일을 컨테이너로 복사
COPY build/libs/*.jar app.jar
COPY .env .env

EXPOSE 8080

ENV $(cat .env | xargs)
ENTRYPOINT ["java", "-jar", "app.jar"]
