package org.example.app.services;

import org.example.web.dto.Book;
import org.example.web.dto.LoginForm;
import org.example.web.dto.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;

/**
 * Created on 02.07.2021
 *
 * @author roland
 **/

@Repository
public class UserRepository   {
    private final static Logger log = LoggerFactory.getLogger(UserRepository.class);

    public List<LoginForm> getUsers() {
        return users;
    }

    private final List<LoginForm> users = new ArrayList<>();

    public void addUser(LoginForm user) {
        log.info("store new book: " + user);
        users.add(user);
    }

    public UserRepository() {
        users.add(new LoginForm("root", "123"));
        users.add(new LoginForm("roland", "321"));
    }

}
