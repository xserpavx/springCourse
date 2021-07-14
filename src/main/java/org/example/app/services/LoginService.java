package org.example.app.services;

import org.apache.log4j.Logger;
import org.example.web.dto.Book;
import org.example.web.dto.LoginForm;
import org.example.web.dto.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class LoginService {
    private Logger logger = Logger.getLogger(LoginService.class);

    private final UserRepository userRepo;


    @Autowired
    public LoginService(UserRepository userRepo) {
        this.userRepo = userRepo;
    }

    public boolean authenticate(LoginForm loginFrom) {
        logger.info("try auth with user-form: " + loginFrom);
        return userRepo.getUsers().contains(loginFrom);
//        return loginFrom.getUsername().equals("root") && loginFrom.getPassword().equals("123");
    }

    public void addNewUser(LoginForm loginFrom) {
        userRepo.addUser(loginFrom);
    }
}
