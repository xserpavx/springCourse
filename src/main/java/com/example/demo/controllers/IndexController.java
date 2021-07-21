package com.example.demo.controllers;

import com.example.demo.entity.Book;
import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Controller
public class IndexController {

    private final BookService bookService;

    @Autowired
    public IndexController(BookService bookService) {
        this.bookService = bookService;
    }

    @ModelAttribute("recommendBooks")
    public List<Book> recommendBooks() {
        return bookService.getRecomendBooks();
    }

    @ModelAttribute("active")
    public String active() {
        return "main";
    }


    @GetMapping("/")
    public String mainPage(Model model) {
        return "index";
    }


}
