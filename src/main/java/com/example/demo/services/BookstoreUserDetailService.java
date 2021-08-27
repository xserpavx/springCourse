package com.example.demo.services;

import com.example.demo.entity.User;
import com.example.demo.repositories.UserRepository;
import com.example.demo.security.BookstoreUserDetails;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * Created on 20.08.2021
 *
 * @author roland
 **/

@Service
public class BookstoreUserDetailService implements UserDetailsService {

    private final UserRepository bookstoreUserRepository;

    @Autowired
    public BookstoreUserDetailService(UserRepository bookstoreUserRepository) {
        this.bookstoreUserRepository = bookstoreUserRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String s) throws UsernameNotFoundException {
        // Определяем по какому полю авторизуется пользователь, по почте или телефону
        User user;
        if (s.contains("@")) {
            user = bookstoreUserRepository.findBookstoreUserByEmail(s);
        } else {
            user = bookstoreUserRepository.findBookstoreUserByPhone(s);
        }
        if (user != null) {
            return new BookstoreUserDetails(user);
        } else {
            if (s.contains("@")) {
                throw new UsernameNotFoundException(String.format("user by e-mail \"%s\" not found!", s));
            } else {
                throw new UsernameNotFoundException(String.format("user by phone \"%s\" not found!", s));
            }
        }
    }

    public UserDetails loadUserByName(String s) throws UsernameNotFoundException {
        User user = bookstoreUserRepository.findBookstoreUserByName(s);
        if (user != null) {
            return new BookstoreUserDetails(user);
        } else {
            throw new UsernameNotFoundException(String.format("user by e-mail \"%s\" not found!", s));
        }
    }






}
