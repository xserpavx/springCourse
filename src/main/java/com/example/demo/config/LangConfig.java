package com.example.demo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor;
import org.springframework.web.servlet.i18n.SessionLocaleResolver;

import java.util.Locale;

/**
 * Created on 20.07.2021
 *
 * @author roland
 **/
@Configuration
public class LangConfig implements WebMvcConfigurer {

    @Bean
    public LocaleResolver localeResolver() {
        //FIXME используйте абстракции или var,
        // т.е. вместо SessionLocaleResolver sessionLocaleResolver = new SessionLocaleResolver();
        // var sessionLocaleResolver = new SessionLocaleResolver();
        // или
        // AbstractLocaleContextResolver sessionLocaleResolver = new SessionLocaleResolver();
        SessionLocaleResolver sessionLocaleResolver = new SessionLocaleResolver();
        sessionLocaleResolver.setDefaultLocale(Locale.ENGLISH);
        return sessionLocaleResolver;
    }

    @Bean
    public LocaleChangeInterceptor localeChangeInterceptor() {
        //FIXME используйте абстракции или var
        LocaleChangeInterceptor localeChangeInterceptor = new LocaleChangeInterceptor();
        localeChangeInterceptor.setParamName("lang");
        return localeChangeInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(localeChangeInterceptor());
    }
}