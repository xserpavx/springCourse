package com.example.demo.security;

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

    private final BookstoreUserRepository bookstoreUserRepository;

    @Autowired
    public BookstoreUserDetailService(BookstoreUserRepository bookstoreUserRepository) {
        this.bookstoreUserRepository = bookstoreUserRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String s) throws UsernameNotFoundException {
        // Определяем по какому полю авторизуется пользователь, по почте или телефону
        BookstoreUser bookstoreUser;
        if (s.contains("@")) {
            bookstoreUser = bookstoreUserRepository.findBookstoreUserByEmail(s);
        } else {
            bookstoreUser = bookstoreUserRepository.findBookstoreUserByPhone(s);
        }
        if (bookstoreUser != null) {
            return new BookstoreUserDetails(bookstoreUser);
        } else {
            if (s.contains("@")) {
                throw new UsernameNotFoundException(String.format("user by e-mail \"%s\" not found!", s));
            } else {
                throw new UsernameNotFoundException(String.format("user by phone \"%s\" not found!", s));
            }
        }
    }

    public UserDetails loadUserByName(String s) throws UsernameNotFoundException {
        BookstoreUser bookstoreUser = bookstoreUserRepository.findBookstoreUserByName(s);
        if (bookstoreUser != null) {
            return new BookstoreUserDetails(bookstoreUser);
        } else {
            throw new UsernameNotFoundException(String.format("user by e-mail \"%s\" not found!", s));
        }
    }






}
