# Описание проекта
Книжный магазин BOOKSHOP - это учебный проект, для освоения фреймворка Spring, Thymeleaf, JPA, Liquibase, REST и других технологий построения Web приложений
# Используемые в проекте технологии
* spring-boot-starter-data-jpa
Элементы ORM для упрощения работы со сведениями из БД
* spring-boot-starter-web
Элементы для создания MVC приложения
* spring-boot-starter-thymeleaf
Шаблонизатор HTML страниц
* spring-boot-starter-jdbc
Работа с базами данных на уровне SQL запросов
* liquibase
Система контроля версий для баз данных
* swagger
Фреймворк для спецификации RESTful API
* rest-api
Приложение реализует API для доступа к данным согласно архитектуре REST
# Используемые профили
## Профиль dev
Профиль, используемый разработчиками приложения. В этом профиле выполняются обновления структуры БД при помощи jpa.hibernate на основе бинов
Используется отдельная (опытная) база данных, для которой отключена система контроля версий liquibase
# Запуск приложения
Первоначальный запуск приложения с созданием структуры БД и занесением первоначальной информации занимает 3-4 минуты
## Maven
Сборка и запуск проекта при помощи Maven осуществляется командой:
```cmd
mvn spring-boot:run 
```
или при помощи скрипта startApp.bat
A для запуска приложения с занесением первоначальных сведений - командой:
```cmd
mvn spring-boot:run
```
или при помощи скрипта startAppInit.bat
## Java
Сборка проекта в jar пакет и запуск этого пакета выполняются командами:
```cmd
mvn clean package
java -jar target\demo-0.0.1-SNAPSHOT.jar
```
или скриптами createJar.bat, а затем startJar.bat
А для запуска приложения с занесением первоначальных сведений
```cmd
mvn clean package
java -jar target\demo-0.0.1-SNAPSHOT.jar
```
