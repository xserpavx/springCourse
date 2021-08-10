package com.example.demo.controllers.rest;

import com.example.demo.entity.Book;
import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created on 11.08.2021
 *
 * @author roland
 **/
@RestController
@RequestMapping("/api/search")
public class SearchRestApiController {
    public final BookService bookService;

    @Autowired
    public SearchRestApiController(BookService bookService) {
        this.bookService = bookService;
    }

    @GetMapping("/page/{searchTitle}")
    @ResponseBody
    public ResponseEntity<List<Book>> searchPage(@PathVariable String searchTitle, @RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit, Model model) {
        List<Book> books = bookService.getPageBookByTitleContain(searchTitle, offset, limit).getContent();
        return books.size() != 0 ? ResponseEntity.ok(books) :
                new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
