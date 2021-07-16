package org.example.app.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Created on 17.07.2021
 *
 * @author roland
 **/
@Configuration
@EnableWebSecurity
public class AppSecurityConfig extends WebSecurityConfigurerAdapter {
    private final static Logger log = LoggerFactory.getLogger(AppSecurityConfig.class);

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.inMemoryAuthentication()
                .withUser("root")
                .password(passwordEncoder().encode("123"))
                .roles("USER");
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
                .csrf().disable() // отключение cross site reference forgery (не рекомендуется. но пока так во избежание доп. настроек)
                .authorizeRequests() // авторизация запросов
                .antMatchers("/login*").permitAll() // страницы обработки начинаются с /login
                .anyRequest().authenticated() // все запросы должны пройти аутентификацию
                .and()
                .formLogin().loginPage("/login") //указываем форму для логина
                .loginProcessingUrl("/login/auth") // процесс обработки авторизации ???
                .defaultSuccessUrl("/books/shelf", true) // переход при успешной авторизации
                .failureUrl("/login"); // переход при неуспешной авторизации
    }

    @Override
    public void configure(WebSecurity web) throws Exception {
        web
                .ignoring()
                .antMatchers("/images/**") // пропускаем запросы к ресурсам
                .antMatchers("/register/**"); // пропускаем запросы к странице регистрации нового пользователя;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
