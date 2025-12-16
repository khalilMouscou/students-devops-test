# Étape 1 : utiliser une image Java
FROM eclipse-temurin:17-jdk-alpine

# Étape 2 : définir le répertoire de travail
WORKDIR /app

# Étape 3 : copier le jar compilé
COPY target/student-management-0.0.1-SNAPSHOT.jar app.jar

# Étape 4 : exposer le port
EXPOSE 8089

# Étape 5 : démarrer l’application
ENTRYPOINT ["java","-jar","app.jar"]
