# Описание проекта
Книжный магазин BOOKSHOP - это учебный проект, для освоения фреймворка Spring, Thymeleaf и других технологий построения Web приложений
# Используемые в проекте технологии
* spring-boot-starter-data-jpa
* spring-boot-starter-web
* spring-boot-starter-thymeleaf
* spring-boot-starter-jdbc
# Запуск приложения
## Maven
Сборка и запуск проекта при помощи Maven осуществляется командой:
```cmd
mvn spring-boot:run 
```
или при помощи скрипта startApp.bat
## Java
Сборка проекта в jar пакет и запуск этого пакета выполняются командами:
```cmd
mvn clean package
java -jar target\demo-0.0.1-SNAPSHOT.jar
```
или скриптами createJar.bat, а затем startJar.bat