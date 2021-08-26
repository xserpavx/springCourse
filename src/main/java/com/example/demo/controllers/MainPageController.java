package com.example.demo.controllers;

import com.example.demo.entity.Book;
import com.example.demo.entity.Tag;
import com.example.demo.services.BookService;
import com.example.demo.services.ControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.List;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Controller
public class MainPageController {

    private final BookService bookService;
    private final ControllerService controllerService;

    @Autowired
    public MainPageController(BookService bookService, ControllerService controllerService) {
        this.bookService = bookService;
        this.controllerService = controllerService;
    }

    @ModelAttribute("isLogged")
    public Boolean isLogged() {
        return !(SecurityContextHolder.getContext().getAuthentication().getPrincipal().toString().compareTo("anonymousUser") == 0);
    }

    @ModelAttribute("ppCount")
    public int ppCount(@CookieValue(name="ppCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
    }

    @ModelAttribute("cartCount")
    public int cartCount(@CookieValue(name="cartCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
    }


    @ModelAttribute("recommendBooks")
    public List<Book> recommendBooks() {
        return bookService.getRecomendBooks(0, 6).getContent();
    }

    @ModelAttribute("tags")
    public List<Tag> getTags() {
        return bookService.getAllTags();
    }

    @ModelAttribute("tag_divider")
    public int calcTagDivider() {
        return bookService.getMaxTag() / 4;
    }

    @ModelAttribute("popularBooks")
    public List<Book> popularBooks() {
        return bookService.getPagePopularBooks(0, 6).getContent();
    }

    @ModelAttribute("recentBooks")
    public List<Book> recentBooks() {
        return bookService.getPageRecentBooks(0, 6).getContent();
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
