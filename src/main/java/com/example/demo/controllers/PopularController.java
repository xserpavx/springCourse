package com.example.demo.controllers;

import com.example.demo.entity.Book;
import com.example.demo.entity.User;
import com.example.demo.services.BookService;
import com.example.demo.services.ControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CookieValue;
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
public class PopularController {

    private final BookService bookService;
    private final ControllerService controllerService;

    @Autowired
    public PopularController(BookService bookService, ControllerService controllerService) {
        this.bookService = bookService;
        this.controllerService = controllerService;
    }

    @ModelAttribute("authUser")
    public User checkAuth() {
        return controllerService.addCurrentUser2Model();
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
        return "popular";
    }

    @ModelAttribute("listBooks")
    public List<Book> recommendBooks() {
        return bookService.getPagePopularBooks(0, 20).getContent();
    }

    @GetMapping("/popularPage")
    public String popularPage() {
        return "books/popular";
    }
}
