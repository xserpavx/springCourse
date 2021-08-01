package com.example.demo.controllers;


import com.example.demo.entity.Book;
import com.example.demo.services.BookService;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created on 30.07.2021
 *
 * @author roland
 **/
@RestController
@RequestMapping("/api")
public class BooksRestApiController {
    public final BookService bookService;

    @Autowired
    public BooksRestApiController(BookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping(value = "/books/recent")
    @ApiOperation("execute to get list books which dates of publication less current date by 2 years")
    public ResponseEntity<List<Book>> recentBooks() {
        return ResponseEntity.ok(bookService.getRecentBooks());
    }


    @GetMapping(value = "/books/by-author" )
    @ApiOperation("execute to get list books from bookshop by passed author name")
    public ResponseEntity<List<Book>> booksByAuthor(@RequestParam("author") String author) {
        return ResponseEntity.ok(bookService.getBooksByAuthor(author));
    }

    @GetMapping(value = "/books/hQuery" )
    @ApiOperation("execute to get bestseller books from bookshop")
    public ResponseEntity<List<Book>> hQuery() {
        return ResponseEntity.ok(bookService.getHQuery());
    }

    @ApiOperation("execute to get list books from bookshop with discount more than 30%")
    @GetMapping(value = "/books/nativeQuery")
    public ResponseEntity<List<Book>> nativeQuery() {
        return ResponseEntity.ok(bookService.getNativeQuery());
    }
}
