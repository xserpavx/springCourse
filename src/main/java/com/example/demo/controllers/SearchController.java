package com.example.demo.controllers;


import com.example.demo.entity.Book;
import com.example.demo.services.BookService;
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

    @Autowired
    public SearchController(BookService bookService) {
        this.bookService = bookService;
    }

    @ModelAttribute("active")
    public String active() {
        return "search";
    }

    private String endless(Integer count) {
        if (count <= 10) {
            switch (count) {
                case 1: return "a";
                case 2: case 3: case 4: return "и";
                default: return "";
            }
        }
        else if (count > 10 && count < 20) {
            return "";
        } else {
            switch (count % 10) {
                case 1: return "а";
                case 2: case 3: case 4: return "и";
                default: return "";
            }
        }

    }

    @GetMapping("/main")
    public String searchPage() {
        return "search/index";
    }

    @GetMapping("/{text}")
    public String searchPostPage(@PathVariable String text, Model model) {
        List<Book> books = bookService.getPageBookByTitleContain(text, 0, 20).getContent();
        model.addAttribute("listBooks", books);
        model.addAttribute("searchTitle", text);
        model.addAttribute("endless", endless(books.size()));
        return "search/index";
    }
}
