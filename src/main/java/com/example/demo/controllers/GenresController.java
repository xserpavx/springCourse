package com.example.demo.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/genres")
public class GenresController {
    private final static Logger log = LoggerFactory.getLogger(GenresController.class);

    @GetMapping("/main")
    public String getMainPage(Model model) {
        model.addAttribute("active", "genres");
        return "/genres/index";
    }
}
