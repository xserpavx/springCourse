package org.example;

import org.example.web.config.WebConfigXML;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.WebApplicationInitializer;
import org.springframework.web.context.ContextLoaderListener;
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext;
import org.springframework.web.context.support.XmlWebApplicationContext;
import org.springframework.web.servlet.DispatcherServlet;

import javax.servlet.ServletException;
import javax.servlet.ServletRegistration;

/**
 * Created on 13.07.2021
 * Класс инициализации Web приложения. Замена web.xml
 * @author roland
 **/

public class ApplicationInit implements WebApplicationInitializer {
    private final static Logger log = LoggerFactory.getLogger(ApplicationInit.class);

    @Override
    public void onStartup(javax.servlet.ServletContext servletContext) throws ServletException {
        /* Замена конфигурации web.xml конфига на java
        <context-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:app-config.xml</param-value>
        </context-param>

        <listener>
            <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
        </listener>
        */
        XmlWebApplicationContext applicationContext = new XmlWebApplicationContext();
        applicationContext.setConfigLocation("classpath:app-config.xml");
        servletContext.addListener(new ContextLoaderListener(applicationContext));

        /*
        <servlet>
            <servlet-name>my-dispatcher-servlet</servlet-name>
            <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
            <init-param>
                <param-name>contextConfigLocation</param-name>
                <param-value>classpath:web-config.xml</param-value>
            </init-param>
            <load-on-startup>1</load-on-startup>
        </servlet>
        <servlet-mapping>
            <servlet-name>my-dispatcher-servlet</servlet-name>
            <url-pattern>/</url-pattern>
        </servlet-mapping>
         */

//        XmlWebApplicationContext webApplicationContext = new XmlWebApplicationContext();
//        webApplicationContext.setConfigLocation("classpath:web-config.xml");

        AnnotationConfigWebApplicationContext webApplicationContext = new AnnotationConfigWebApplicationContext();
        webApplicationContext.register(WebConfigXML.class);

        DispatcherServlet dispatcherServlet = new DispatcherServlet(webApplicationContext);
        ServletRegistration.Dynamic dispatcher = servletContext.addServlet("dispatcher", dispatcherServlet);
        dispatcher.setLoadOnStartup(1);
        dispatcher.addMapping("/");
    }
}
