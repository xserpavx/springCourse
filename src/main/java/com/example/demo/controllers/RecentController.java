package com.example.demo.controllers;

import com.example.demo.entity.Book;
import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/books")
public class RecentController {

    private final BookService bookService;

    @Autowired
    public RecentController(BookService bookService) {
        this.bookService = bookService;
    }

    @ModelAttribute("listBooks")
    public List<Book> recommendBooks() {
        return bookService.getRecentBooks();
    }

    @ModelAttribute("active")
    public String active() {
        return "recent";
    }

    @GetMapping("/recentPage")
    public String recentPage() {
        return "books/recent";
    }
}
