package com.example.demo.repositories;

import com.example.demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Created on 20.08.2021
 *
 * @author roland
 **/
@Repository
public interface UserRepository extends JpaRepository<User, Integer> {
    User findBookstoreUserByEmail(String email);

    User findBookstoreUserByName(String userName);

    User findBookstoreUserByPhone(String phone);

    User findUserByNameAndOauthId(String name, String oAuthId);

}
