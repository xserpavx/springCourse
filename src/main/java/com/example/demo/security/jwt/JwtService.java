package com.example.demo.security.jwt;

import com.example.demo.entity.AccessToken;
import com.example.demo.exceptions.JwtTimeoutException;
import com.example.demo.repositories.TokenRepository;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

/**
 * Created on 22.08.2021
 *
 * @author roland
 **/
@Service
public class JwtService {

    private final TokenRepository tokenRepository;

    public JwtService(TokenRepository tokenRepository) {
        this.tokenRepository = tokenRepository;
    }

    @Value("${auth.secret}")
    private String secret;


    private Map<String, Date> jwtBlackList = new HashMap<>();
    @Getter
    private Map<String, UserDetails> jwtList = new HashMap<>();

    public void markLogoutEventForToken(String token) throws JwtTimeoutException {
        if (jwtBlackList.containsKey(token)) {
            System.out.println(String.format("Log out token for user [%s] is already present in the cache", this.tokenUserName(token)));
        } else {
            Date tokenExpiryDate = this.tokenExpiration(token);
            System.out.println(String.format("Logout token cache set for [%s]. Token is due expiry at [%s]", this.tokenUserName(token), tokenExpiryDate));
            jwtBlackList.put(token, new Date());
            jwtList.remove(token);
        }
    }

    public Date getLogoutEventForToken(String token) {
        return jwtBlackList.get(token);
    }

    private String createToken(Map<String, Object> claims, String userName, long ttl) {
        return Jwts
                .builder()
                .setClaims(claims)
                .setSubject(userName)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + ttl ))
                .signWith(SignatureAlgorithm.HS256, secret).compact();

    }

    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        AccessToken accessToken = new AccessToken();
        accessToken.setAccessToken(createToken(claims, userDetails.getUsername(), 1000 * 60));
        accessToken.setRefreshToken(createToken(claims, userDetails.getUsername(), 1000 * 3600 * 24 * 60));
        accessToken.setUserName(userDetails.getUsername());
        tokenRepository.save(accessToken);
        return accessToken.getAccessToken();
    }

    public String refreshToken(String token) {
        UserDetails userDetails = jwtList.get(token);
        if (userDetails != null) {
            return generateToken(userDetails);
        } else  {
            return token;
        }
    }


    public <T> T extractClaims(String token, Function<Claims, T> claimsResolver) throws JwtTimeoutException {
        Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) throws JwtTimeoutException  {
        try {
            return Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
        } catch (Exception e) {
            throw new JwtTimeoutException("Авторизационный токен устарел. Необходимо авторизоваться заново");
        }
    }

    public String tokenUserName(String token) throws JwtTimeoutException{
        return extractClaims(token, Claims::getSubject);
    }

    public Date tokenExpiration(String token) throws JwtTimeoutException{
        return extractClaims(token, Claims::getExpiration);
    }

    public Boolean isTokenExpired(String token) throws JwtTimeoutException{
        return tokenExpiration(token).before(new Date());
    }

    public Boolean validateToken(String token, UserDetails userDetails) throws JwtTimeoutException{
        Date logoutDate = getLogoutEventForToken(token);
        if (logoutDate != null) {
            String errorMessage = String.format("Token corresponds to an already logged out user [%s] at [%s]. Please login again", this.tokenUserName(token), logoutDate);
            System.out.println(errorMessage);
            return false;
//            throw new InvalidTokenRequestException("JWT", authToken, errorMessage);
        }

        String userName= tokenUserName(token);
        return userName.equals(userDetails.getUsername()) && !isTokenExpired(token);
    }


}
