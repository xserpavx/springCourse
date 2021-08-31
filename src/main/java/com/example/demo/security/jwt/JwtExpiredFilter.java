package com.example.demo.security.jwt;

import com.example.demo.exceptions.JwtTimeoutException;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Created on 30.08.2021
 *
 * @author roland
 **/
@Component
public class JwtExpiredFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    public JwtExpiredFilter(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, FilterChain filterChain) throws ServletException, IOException {
        String token = null;
        String userName = null;
        Cookie[] cookies = httpServletRequest.getCookies();

        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("token")) {
                    token = cookie.getValue();
                    try {
                        userName = jwtService.tokenUserName(token);
                    } catch (JwtTimeoutException e) {
                        httpServletRequest.getRequestDispatcher("login").forward(httpServletRequest, httpServletResponse);
                        return;
                    }
                }
            }
        }
        filterChain.doFilter(httpServletRequest, httpServletResponse);
    }
}
