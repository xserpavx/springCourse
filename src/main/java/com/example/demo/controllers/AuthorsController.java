package com.example.demo.controllers;

import com.example.demo.entity.Author;
import com.example.demo.entity.User;
import com.example.demo.services.AuthorService;
import com.example.demo.services.ControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

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
    private final ControllerService controllerService;

    @Autowired
    public AuthorsController(AuthorService authorService, ControllerService controllerService) {
        this.authorService = authorService;
        this.controllerService = controllerService;
    }

    @ModelAttribute("authUser")
    public User checkAuth() {
        return controllerService.getCurrentUser();
    }

    @ModelAttribute("ppCount")
    public int ppCount(@CookieValue(name="ppCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
    }

    @ModelAttribute("cartCount")
    public int cartCount(@CookieValue(name="cartCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
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

    @GetMapping("/{slug}")
    public String getSlugPage(@PathVariable String slug, Model model) {
        try {
            List<Author> authors = authorService.getAuthorBySlug(slug);
            if (!authors.isEmpty()) {
                model.addAttribute("author", authors.get(0));
                return "authors/slug";
            }
        } catch (NumberFormatException e) {
            return "";
        }
        return "";
    }
}
