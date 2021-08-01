package com.example.demo.controllers;

import com.example.demo.entity.Author;
import com.example.demo.services.AuthorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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
    public Map<String, List<Author>> authors() {
        return authorService.getAuthors();
    }

    @GetMapping("/main")
    public String getMainPage() {
        return "authors/index";
    }

    @GetMapping("/slug/{id}")
    public String getSlugPage(@PathVariable String id, Model model) {
        try {
            List<Author> authors = authorService.getAuthorById(Integer.parseInt(id));
            if (authors.size() != 0) {
                model.addAttribute("author",authors.get(0));
                return "authors/slug";
            }
        } catch (NumberFormatException e) {
            return "";
        }
        return "";
    }
}
