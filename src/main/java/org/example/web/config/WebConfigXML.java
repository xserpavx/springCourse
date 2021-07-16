package org.example.web.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.multipart.commons.CommonsMultipartResolver;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.thymeleaf.spring5.SpringTemplateEngine;
import org.thymeleaf.spring5.templateresolver.SpringResourceTemplateResolver;
import org.thymeleaf.spring5.view.ThymeleafViewResolver;

/**
 * Created on 13.07.2021
 * Замена конфигурационного файла web-config.xml
 * @author roland
 **/

@Configuration
@ComponentScan (basePackages = "org.example.web") // <context:component-scan base-package="org.example.web"/>
@EnableWebMvc // <mvc:annotation-driven/>

public class WebConfigXML implements WebMvcConfigurer {
    private final static Logger log = LoggerFactory.getLogger(WebConfigXML.class);

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // <mvc:resources mapping="/**" location="classpath:images"/>
        registry.addResourceHandler("/**").addResourceLocations("classpath:/images");
    }

    /*
    <!-- SpringResourceTemplateResolver автоматически интегрируется с собственной           -->
    <!-- инфраструктурой Spring для обработки web-ресурсов и необходим SpringTemplateEngine -->
    <bean id="templateResolver"
    class="org.thymeleaf.spring5.templateresolver.SpringResourceTemplateResolver">
        <property name="prefix" value="/WEB-INF/views/"/>
        <property name="suffix" value=".html"/>
        <!-- HTML - значение по умолчанию. Добавлено здесь для большей ясности.              -->
        <property name="templateMode" value="HTML"/>
        <!-- Cache страниц по-умолчанию имеет значение true. Установите в false, если хотите -->
        <!-- чтобы шаблоны автоматически обновлялись при их изменении.                       -->
        <property name="cacheable" value="true"/>
    </bean>
    */
    @Bean
    public SpringResourceTemplateResolver templateresolver() {
        SpringResourceTemplateResolver templateresolver = new SpringResourceTemplateResolver();
        templateresolver.setPrefix("/WEB-INF/views/");
        templateresolver.setSuffix(".html");
        templateresolver.setCacheable(false);
        templateresolver.setTemplateMode("HTML5");

        return templateresolver;
    }

    /*
    <!-- SpringTemplateEngine автоматически добавляет SpringStandardDialect -->
    <bean id="templateEngine"
          class="org.thymeleaf.spring5.SpringTemplateEngine">
        <property name="templateResolver" ref="templateResolver"/>
        <!-- Включение компилятора SpringEL в Spring 4.2.4 или новее может ускорить -->
        <!-- выполнение в большинстве сценариев, но может быть несовместимо с конкретными -->
        <!-- случаями, когда выражения на одной странице повторно используются в разных данных, -->
        <!-- так что этот флаг по умолчанию имеет значение «false» для более безопасной обратной -->
        <!-- совместимости. -->
        <property name="enableSpringELCompiler" value="true"/>
    </bean>
     */

    @Bean
    public SpringTemplateEngine springTemplateEngine() {
        SpringTemplateEngine springTemplateEngine = new SpringTemplateEngine();
        springTemplateEngine.addTemplateResolver(templateresolver());
        springTemplateEngine.setEnableSpringELCompiler(true);
        return springTemplateEngine;
    }

    /*
        <bean class="org.thymeleaf.spring5.view.ThymeleafViewResolver">
        <property name="templateEngine" ref="templateEngine"/>
        <property name="order" value="1"/>
    </bean>
     */

    @Bean
    public ThymeleafViewResolver thymeleafViewResolver() {
        ThymeleafViewResolver thymeleafViewResolver = new ThymeleafViewResolver();
        thymeleafViewResolver.setTemplateEngine(springTemplateEngine());
        thymeleafViewResolver.setOrder(1);
        return thymeleafViewResolver;
    }

    @Bean
    public CommonsMultipartResolver multipartResolver() {
        CommonsMultipartResolver commonsMultipartResolver = new CommonsMultipartResolver();
//        Ограничение на максимальный размер файла
        commonsMultipartResolver.setMaxUploadSize(5000000);
        return commonsMultipartResolver;
    }


}
