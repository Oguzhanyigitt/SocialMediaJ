# 1. AŞAMA: Derleme (Maven ile projeyi derleyip .war dosyasını oluştururuz)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package

# 2. AŞAMA: Çalıştırma (Tomcat 10 sunucusunu kurup .war dosyasını içine atarız)
FROM tomcat:10.1-jdk17
# Maven'ın ürettiği dosyayı Tomcat'in ana (ROOT) dizinine kopyalıyoruz
COPY --from=build /app/target/social-media-app-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Tomcat'in standart portunu açıyoruz
EXPOSE 8080

# Sunucuyu başlatma komutu
CMD ["catalina.sh", "run"]