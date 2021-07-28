# Описание проекта
Книжный магазин BOOKSHOP - это учебный проект, для освоения фреймворка Spring, Thymeleaf и других технологий построения Web приложений
# Используемые в проекте технологии
* spring-boot-starter-data-jpa
* spring-boot-starter-web
* spring-boot-starter-thymeleaf
* spring-boot-starter-jdbc
# Используемые профили
## Профиль initUtf
Данный профиль используется при ПЕРВОМ запуске приложения средой разработки IntelliJ IDEA.
В данном профиле выполняется занесение первоначальных сведений в базу данных из скрипта в кодировке UTF8
## Профиль initWin
Данный профиль используется при ПЕРВОМ запуске приложения средствами maven (сборка и запуск проекта) или java (запуск из скомпилированного jar файла)
В данном профиле выполняется занесение первоначальных сведений в базу данных из скрипта в кодировке Win1251
# Запуск приложения
## Maven

Сборка и запуск проекта при помощи Maven осуществляется командой:
```cmd
mvn spring-boot:run 
```
или при помощи скрипта startApp.bat
A для запуска приложения с занесением первоначальных сведений - командой:
```cmd
mvn spring-boot:run -Dspring-boot.run.profiles=initWin 
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
java -jar -Dspring.profiles.active=initWin target\demo-0.0.1-SNAPSHOT.jar
```