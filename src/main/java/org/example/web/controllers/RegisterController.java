package org.example.web.controllers;

import org.example.web.dto.LoginForm;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Created on 03.07.2021
 *
 * @author roland
 **/

@Controller
@RequestMapping(value = "/register")
public class RegisterController {
    private final static Logger log = LoggerFactory.getLogger(RegisterController.class);

    @GetMapping
    public String register(Model model) {
        log.info("GET /login returns login_page.html");
        model.addAttribute("loginForm", new LoginForm());
        return "register_page";
    }
}
