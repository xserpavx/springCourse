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
public class AboutController {
    @ModelAttribute("active")
    public String active() {
        return "about";
    }

    @GetMapping("/about")
    public String aboutPage() {
        return "about";
    }
}