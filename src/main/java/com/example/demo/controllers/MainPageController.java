package com.example.demo.controllers;

import com.example.demo.entity.Book;
import com.example.demo.entity.Tag;
import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
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

    @Autowired
    public MainPageController(BookService bookService) {
        this.bookService = bookService;
    }

    @ModelAttribute("recommendBooks")
    public List<Book> recommendBooks() {
        return bookService.getPageAllBooks(0,6).getContent();
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
        return bookService.getPagePopularBooks(0,6).getContent();
    }

    @ModelAttribute("recentBooks")
    public List<Book> recentBooks() {
        return bookService.getPageRecentBooks(0,6).getContent();
    }

    @ModelAttribute("active")
    public String active() {
        return "main";
    }


    @GetMapping("/")
    public String mainPage(Model model) {
        return "index";
    }

//    @GetMapping("/books/recommended")
//    @ResponseBody
//    public BookListDto getRecomendedBooks(@RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
//        return new BookListDto(bookService.getPageAllBooks(offset, limit).getContent());
//    }
//
//    @GetMapping("/books/popular")
//    @ResponseBody
//    public BookListDto getPopularBooks(@RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
//        return new BookListDto(bookService.getPagePopularBooks(offset, limit).getContent());
//    }
}
