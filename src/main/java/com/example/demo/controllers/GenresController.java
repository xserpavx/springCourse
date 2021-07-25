package com.example.demo.controllers;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/genres")
public class GenresController {

    @ModelAttribute("active")
    public String active() {
        return "genres";
    }

    @GetMapping("/main")
    public String getMainPage() {
        return "genres/index";
    }

    @GetMapping("/slug")
    public String getSlugPage() {
        return "genres/slug";
    }
}
