package com.example.demo.controllers;


import com.example.demo.entity.Book;
import com.example.demo.entity.User;
import com.example.demo.services.BookService;
import com.example.demo.services.ControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/search")
public class SearchController {

    private final BookService bookService;
    private final ControllerService controllerService;

    @Autowired
    public SearchController(BookService bookService, ControllerService controllerService) {
        this.bookService = bookService;
        this.controllerService = controllerService;
    }

    @ModelAttribute("active")
    public String active() {
        return "search";
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

    private String endless(Integer count) {
        return ControllerService.getEnding(count, "а", "и", "");
//        if (count <= 10) {
//            switch (count) {
//                case 1: return "a";
//                case 2: case 3: case 4: return "и";
//                default: return "";
//            }
//        }
//        else if (count > 10 && count < 20) {
//            return "";
//        } else {
//            switch (count % 10) {
//                case 1: return "а";
//                case 2: case 3: case 4: return "и";
//                default: return "";
//            }
//        }
    }

    @GetMapping("/main")
    public String searchPage() {
        return "search/index";
    }

    @GetMapping("/{searchTitle}")
    public String search(@PathVariable String searchTitle, Model model) {
        List<Book> books = bookService.getBookByTitleContain(searchTitle);

        model.addAttribute("listBooks", bookService.getPageBookByTitleContain(searchTitle, 0, 20).getContent());
        model.addAttribute("searchTitle", searchTitle);
        model.addAttribute("endless", endless(books.size()));
        model.addAttribute("totalBooksCount", books.size());
        return "search/index";
    }

}
