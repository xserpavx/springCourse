package com.example.demo.controllers;

import com.example.demo.entity.Author;
import com.example.demo.services.AuthorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.TreeMap;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/authors")
public class AuthorsController {
    private final AuthorService authorService;

    @Autowired
    public AuthorsController(AuthorService authorService) {
        this.authorService = authorService;
    }

    @ModelAttribute("active")
    public String active() {
        return "author";
    }

    @ModelAttribute("authors")
    public TreeMap<String, ArrayList<Author>> authors() {
        return authorService.getAuthors();
    }

    @GetMapping("/main")
    public String getMainPage() {
        return "/authors/index";
    }
}
