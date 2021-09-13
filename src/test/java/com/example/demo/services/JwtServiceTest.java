package com.example.demo.services;

import com.example.demo.entity.AccessToken;
import com.example.demo.entity.User;
import com.example.demo.exceptions.JwtTimeoutException;
import com.example.demo.repositories.TokenRepository;
import com.example.demo.repositories.UserRepository;
import com.example.demo.security.BookstoreUserDetails;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
class JwtServiceTest {

    private final BookstoreUserDetailService bookstoreUserDetailService;
    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final TokenRepository tokenRepository;

    @Autowired
    public JwtServiceTest(BookstoreUserDetailService bookstoreUserDetailService, JwtService jwtService, UserRepository userRepository, TokenRepository tokenRepository) {
        this.bookstoreUserDetailService = bookstoreUserDetailService;
        this.jwtService = jwtService;
        this.userRepository = userRepository;
        this.tokenRepository = tokenRepository;
    }


    /**
     * Проверка истечения и обновления токена
     * @throws InterruptedException
     */
    @Test
    public void expirationTokenTest() throws InterruptedException {
        User user = new User();
        user.setName("testUser");
        user.setEmail("testUser@mail.my");
        user.setPassword("resUtset");
        userRepository.save(user);
        try {
            BookstoreUserDetails userDetails = (BookstoreUserDetails) bookstoreUserDetailService.loadUserByUsername(user.getEmail());

            assertEquals(false, userDetails == null, "Loading bookstore user deatils for user \"testUser\" failed!");

            // Генерируем токен, время жизни = 5 сек
            String token = jwtService.generateToken(userDetails, 5000);
            // Ждем 10 секунд
            TimeUnit.SECONDS.sleep(6);
            try {
                jwtService.validateToken(token, userDetails);
                assertEquals(true, false, "Token is not expired!");
            } catch (JwtTimeoutException e) {

            }

            AccessToken accessToken = tokenRepository.findAccessTokenByAccessToken(token);

            assertEquals(true, accessToken != null, "Pair accessToken/refreshToken not found in database!");
            try {
                if (!jwtService.isTokenExpired(accessToken.getRefreshToken())) {
                    BookstoreUserDetails bookstoreUserDetails = (BookstoreUserDetails) bookstoreUserDetailService.loadUserByName(accessToken.getUserName());
                    token = jwtService.generateToken(bookstoreUserDetails, 5000);
                }
            } catch (JwtTimeoutException e2) {
                assertEquals(true, false, "Refresh token expired early!");
            }
            try {
                jwtService.validateToken(token, userDetails);
            } catch (JwtTimeoutException e) {
                assertEquals(true, false, "Grant new accessToken by refresh token failed!");
            }


        } finally {
            userRepository.delete(user);
        }

    }
}