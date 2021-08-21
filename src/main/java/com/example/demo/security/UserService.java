package com.example.demo.security;

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

    @Autowired
    public UserService(BookstoreUserRepository bookstoreUserRepository, PasswordEncoder passwordEncoder, AuthenticationManager authenticationManager) {
        this.bookstoreUserRepository = bookstoreUserRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
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
        response.setResult(true);
        return response;
    }

    public Object getCurrentUser() {
        BookstoreUserDetails bookstoreUserDetails = (BookstoreUserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return bookstoreUserDetails.getBookstoreUser();
    }
}
