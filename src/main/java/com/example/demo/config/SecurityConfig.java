package com.example.demo.config;

import com.example.demo.security.jwt.JwtExpiredFilter;
import com.example.demo.security.jwt.JwtRequestFilter;
import com.example.demo.services.BookstoreUserDetailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.access.channel.ChannelProcessingFilter;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Created on 20.08.2021
 *
 * @author roland
 **/
@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    private final BookstoreUserDetailService bookstoreUserDetailService;
    private final JwtRequestFilter filter;
//    private final AccessDeniedHandler accessDeniedHandler;
    private final JwtExpiredFilter jwtExpiredFilter;

    @Autowired
    public SecurityConfig(BookstoreUserDetailService bookStoreUserDetailService, JwtRequestFilter filter, JwtExpiredFilter jwtExpiredFilter) {
        this.bookstoreUserDetailService = bookStoreUserDetailService;
        this.filter = filter;
        this.jwtExpiredFilter = jwtExpiredFilter;
    }

    @Bean
    PasswordEncoder getPasswordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    @Override
    protected AuthenticationManager authenticationManager() throws Exception {
        return super.authenticationManager();
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth
                .userDetailsService(bookstoreUserDetailService)
                .passwordEncoder(getPasswordEncoder());

    }

    //FIXME попытка исключить страницу с адресом /505 из проверки безопасности чтобы она открылась даже с истекшим токеном.
    // Безуспешно
    @Override
    public void configure(WebSecurity web) throws Exception {
        web.ignoring().antMatchers("/505**");
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http

                .csrf().disable()
                .authorizeRequests()
                .antMatchers("/505").permitAll()
                .antMatchers("/my", "/profile").hasRole("USER")
                .antMatchers("/**").permitAll()
                .and().formLogin()
                .loginPage("/signin").failureUrl("/signin")
                .and().logout().logoutUrl("/logout").logoutSuccessUrl("/signin").deleteCookies("token")
                .and().oauth2Login()
                .and().oauth2Client();
//        http.sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);
        http
                .addFilterBefore(jwtExpiredFilter, ChannelProcessingFilter.class)
                .addFilterBefore(filter, UsernamePasswordAuthenticationFilter.class)

        ;

        ;
    }

}
