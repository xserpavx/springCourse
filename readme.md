# Описание проекта
Книжный магазин BOOKSHOP - это учебный проект, для освоения фреймворка Spring, Thymeleaf и других технологий построения Web приложений
# Используемые в проекте технологии
* spring-boot-starter-data-jpa
* spring-boot-starter-web
* spring-boot-starter-thymeleaf
* spring-boot-starter-jdbc
# Используемые профили
## Профиль idea
Используется при запуске приложения через среду разработки IntelliJ IDEA. 
Изменяет путь к скрипту data.sql
Это связано с тем, что в скрипте для занесения данных в таблицы Books и Authors имеются русские буквы. 
Для корректного отображения сведений из БД H2 IntelliJ IDEA требуется файл в кодировке UTF8, а при запуске
при помощи Maven или Java он требуется в кодировке Win1251.
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
java -jar -Dspring.profiles.active=jar target\demo-0.0.1-SNAPSHOT.jar
```
или скриптами createJar.bat, а затем startJar.bat