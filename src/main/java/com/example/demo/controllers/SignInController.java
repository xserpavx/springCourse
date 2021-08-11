package com.example.demo.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
public class SignInController {
    @ModelAttribute("active")
    public String active() {
        return "signin";
    }

    @GetMapping("/signin")
    public String signinPage() {
        return "signin";
    }
}
