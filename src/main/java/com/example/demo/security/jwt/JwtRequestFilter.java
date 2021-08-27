package com.example.demo.security.jwt;

import com.example.demo.services.BookstoreUserDetailService;
import com.example.demo.security.BookstoreUserDetails;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Created on 22.08.2021
 *
 * @author roland
 **/

@Component
public class JwtRequestFilter extends OncePerRequestFilter {

    private final BookstoreUserDetailService bookstoreUserDetailService;
    private final JwtService jwtService;

    public JwtRequestFilter(BookstoreUserDetailService bookstoreUserDetailService, JwtService jwtService) {
        this.bookstoreUserDetailService = bookstoreUserDetailService;
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
                    userName = jwtService.tokenUserName(token);
                    break;
                }
            }
        }
        if (userName != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            BookstoreUserDetails userDetails = (BookstoreUserDetails) bookstoreUserDetailService.loadUserByName(userName);
            if (userDetails != null) {
                if (jwtService.validateToken(token, userDetails)) {
                    UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                    authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(httpServletRequest));
                    SecurityContextHolder.getContext().setAuthentication(authenticationToken);
                }
            } else {
                throw new UsernameNotFoundException(String.format("user by name \"%s\" not found!", userName));
            }
        }
        filterChain.doFilter(httpServletRequest, httpServletResponse);
    }
}
