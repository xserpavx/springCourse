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
        BookstoreUser bookstoreUser = bookstoreUserRepository.findBookstoreUserByEmail(s);
        if (bookstoreUser != null) {
            return new BookstoreUserDetails(bookstoreUser);
        } else {
            throw new UsernameNotFoundException("user not found!");
        }
    }


}
