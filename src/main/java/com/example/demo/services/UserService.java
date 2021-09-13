package com.example.demo.services;

import com.example.demo.entity.User;
import com.example.demo.repositories.UserRepository;
import com.example.demo.security.BookstoreUserDetails;
import com.example.demo.security.ContactConfirmationPayLoad;
import com.example.demo.security.ContactConfirmationResponse;
import com.example.demo.security.RegistrationForm;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Created on 21.08.2021
 *
 * @author roland
 **/
@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final BookstoreUserDetailService bookstoreUserDetailService;
    private final JwtService jwtService;

    @Autowired
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder,
                       AuthenticationManager authenticationManager, BookstoreUserDetailService bookstoreUserDetailService,
                       JwtService jwtService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.bookstoreUserDetailService = bookstoreUserDetailService;
        this.jwtService = jwtService;
    }

    public void registrationNewUser(RegistrationForm regForm) {
        if (userRepository.findBookstoreUserByEmail(regForm.getEmail()) == null) {
            User user = new User();
            user.setName(regForm.getName());
            user.setPhone(regForm.getPhone());
            user.setEmail(regForm.getEmail());
            user.setPassword(passwordEncoder.encode(regForm.getPassword()));
            userRepository.save(user);
        }
    }

    public ContactConfirmationResponse login(ContactConfirmationPayLoad payload) {
        Authentication authentication = authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(payload.getContact(), payload.getCode()));
        SecurityContextHolder.getContext().setAuthentication(authentication);
        ContactConfirmationResponse response = new ContactConfirmationResponse();
        response.setResult("true");
        return response;
    }

    public ContactConfirmationResponse jwtLogin(ContactConfirmationPayLoad payload) {
        // Необходимо определить что использовалось в качестве имени пользователя: телефон или email

        try {
            authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(payload.getContact(), payload.getCode()));
        } catch (Exception e) {
            e.printStackTrace();
        }

        BookstoreUserDetails bookstoreUserDetails = (BookstoreUserDetails) bookstoreUserDetailService.loadUserByUsername(payload.getContact());
        String jwtToken = jwtService.generateToken(bookstoreUserDetails);
        jwtService.getJwtList().put(jwtToken, bookstoreUserDetails);
        ContactConfirmationResponse response = new ContactConfirmationResponse();
        response.setResult(jwtToken);
        return response;
    }

    public Object getCurrentUser() {
        BookstoreUserDetails bookstoreUserDetails = (BookstoreUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return bookstoreUserDetails.getUser();
    }

    public void registrationOAuthUser(String login, String oAuthId) {
        if (userRepository.findUserByNameAndOauthId(login, oAuthId) == null) {
            User user = new User();
            user.setName(login);
            user.setOauthId(oAuthId);
            userRepository.save(user);
        }
    }

    public User findOAuthUser(String login, String oAuthId) {
        return userRepository.findUserByNameAndOauthId(login, oAuthId);
    }
}
