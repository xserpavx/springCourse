package com.example.demo.security;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Created on 20.08.2021
 *
 * @author roland
 **/
@Repository
public interface BookstoreUserRepository extends JpaRepository<BookstoreUser, Integer> {
    BookstoreUser findBookstoreUserByEmail(String email);

    BookstoreUser findBookstoreUserByName(String userName);

    BookstoreUser findBookstoreUserByPhone(String phone);

}
