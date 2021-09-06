package com.example.demo.security.jwt;

import com.example.demo.entity.AccessToken;
import com.example.demo.exceptions.JwtTimeoutException;
import com.example.demo.repositories.TokenRepository;
import com.example.demo.security.BookstoreUserDetails;
import com.example.demo.services.BookstoreUserDetailService;
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
    private final TokenRepository tokenRepository;
    private BookstoreUserDetailService bookstoreUserDetailService;

    public JwtExpiredFilter(JwtService jwtService, TokenRepository tokenRepository, BookstoreUserDetailService bookstoreUserDetailService) {
        this.jwtService = jwtService;
        this.tokenRepository = tokenRepository;
        this.bookstoreUserDetailService = bookstoreUserDetailService;
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
                        AccessToken accessToken = tokenRepository.findAccessTokenByAccessToken(token);
                        try {
                            if (accessToken != null) {
                                if (!jwtService.isTokenExpired(accessToken.getRefreshToken())) {
                                    BookstoreUserDetails bookstoreUserDetails = (BookstoreUserDetails) bookstoreUserDetailService.loadUserByName(accessToken.getUserName());
                                    Cookie cookie2 = new Cookie("token", jwtService.generateToken(bookstoreUserDetails));
                                    httpServletResponse.addCookie(cookie2);
                                }
                            }
                            tokenRepository.delete(accessToken);
                        } catch (JwtTimeoutException e2) {
                            e2.printStackTrace();
                        }
                    }
                }
            }
        }
        filterChain.doFilter(httpServletRequest, httpServletResponse);
    }
}
