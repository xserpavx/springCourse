package com.example.demo.security;

import com.example.demo.security.jwt.JwtService;
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

    private final BookstoreUserRepository bookstoreUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final BookstoreUserDetailService bookstoreUserDetailService;
    private final JwtService jwtService;

    @Autowired
    public UserService(BookstoreUserRepository bookstoreUserRepository, PasswordEncoder passwordEncoder,
                       AuthenticationManager authenticationManager, BookstoreUserDetailService bookstoreUserDetailService,
                       JwtService jwtService) {
        this.bookstoreUserRepository = bookstoreUserRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.bookstoreUserDetailService = bookstoreUserDetailService;
        this.jwtService = jwtService;
    }

    public void registrationNewUser(RegistrationForm regForm) {
        if (bookstoreUserRepository.findBookstoreUserByEmail(regForm.getEmail()) == null) {
            BookstoreUser bsUser = new BookstoreUser();
            bsUser.setName(regForm.getName());
            bsUser.setPhone(regForm.getPhone());
            bsUser.setEmail(regForm.getEmail());
            bsUser.setPassword(passwordEncoder.encode(regForm.getPassword()));
            bookstoreUserRepository.save(bsUser);
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
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(payload.getContact(), payload.getCode()));
        BookstoreUserDetails bookstoreUserDetails = (BookstoreUserDetails) bookstoreUserDetailService.loadUserByUsername(payload.getContact());
        String jwtToken = jwtService.generateToken(bookstoreUserDetails);
        ContactConfirmationResponse response = new ContactConfirmationResponse();
        response.setResult(jwtToken);
        return response;
    }

    public Object getCurrentUser() {
        BookstoreUserDetails bookstoreUserDetails = (BookstoreUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return bookstoreUserDetails.getBookstoreUser();
    }
}
