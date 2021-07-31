package com.example.demo.controllers;

import com.example.demo.data.BookListDto;
import com.example.demo.entity.Book;
import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

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

    @GetMapping("/books/recommended")
    @ResponseBody
    public BookListDto getRecomendedBooks(@RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
        return new BookListDto(bookService.getPageRecentBooks(offset, limit).getContent());
    }

    @GetMapping("/books/recent")
    @ResponseBody
    public BookListDto getRecentBooks(@RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
        return new BookListDto(bookService.getPageRecentBooks(offset, limit).getContent());
    }

    @GetMapping("/books/popular")
    @ResponseBody
    public BookListDto getPopularBooks(@RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
        return new BookListDto(bookService.getPageRecentBooks(offset, limit).getContent());
    }
}
