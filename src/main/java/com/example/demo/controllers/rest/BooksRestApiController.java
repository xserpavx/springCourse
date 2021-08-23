package com.example.demo.controllers.rest;

import com.example.demo.dto.DtoBooks;
import com.example.demo.entity.Book;
import com.example.demo.services.BookService;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.annotations.ApiOperation;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.text.ParseException;
import java.text.SimpleDateFormat;
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

    @ApiOperation("execute to get list books from bookshop by passed author name")
    @GetMapping(value = "/books/by-author")
    public ResponseEntity<List<Book>> booksByAuthor(@RequestParam("author") String author) {
        List<Book> books = bookService.getBooksByAuthor(author);
        return !books.isEmpty()
                ? ResponseEntity.ok(books)
                : new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @ApiOperation("execute to get bestseller books from bookshop")
    @GetMapping(value = "/books/hQuery")
    public ResponseEntity<List<Book>> hQuery() {
        List<Book> books = bookService.getHQuery();
        return !books.isEmpty()
                ? ResponseEntity.ok(books)
                : new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @ApiOperation("execute to get list books from bookshop with discount more than 30%")
    @GetMapping(value = "/books/nativeQuery")
    public ResponseEntity<List<Book>> nativeQuery() {
        List<Book> books = bookService.getNativeQuery();
        return !books.isEmpty()
                ? ResponseEntity.ok(books)
                : new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @ApiOperation("execute to get list books from bookshop by ID of tags")
    @GetMapping(value = "/books/tag/{id}")
    public ResponseEntity<DtoBooks> getBooksByTag(@PathVariable String id,
                                                    @RequestParam("offset") Integer offset,
                                                    @RequestParam("limit") Integer limit) {
        DtoBooks dtoBooks = new DtoBooks(bookService.getPageBooksByTag(id, offset, limit).getContent());
        return ResponseEntity.ok(dtoBooks);
    }


    @ApiOperation("execute to get list books from bookshop by SLUG of genre")
    @GetMapping("/books/genre/{slug}")
    public ResponseEntity<DtoBooks> getBooksByGenre(@PathVariable String slug, @RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
        DtoBooks dtoBooks = new DtoBooks(bookService.getPageBooksByGenre(slug, offset, limit).getContent());
        return ResponseEntity.ok(dtoBooks);
    }

    @ApiOperation("execute to get list recomended books from bookshop")
    @GetMapping("/books/recommended")
    public ResponseEntity<DtoBooks> getRecomendedBooks(@RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
        DtoBooks dtoBooks = new DtoBooks(bookService.getPageAllBooks(offset, limit).getContent());
        return ResponseEntity.ok(dtoBooks);
    }

    @ApiOperation("execute to get list popular books from bookshop")
    @GetMapping("/books/popular")
    public ResponseEntity<DtoBooks> getPopularBooks(@RequestParam("offset") Integer offset,
                                                      @RequestParam("limit") Integer limit) {
        DtoBooks dtoBooks = new DtoBooks(bookService.getPagePopularBooks(offset, limit).getContent());
        return ResponseEntity.ok(dtoBooks);
    }

    @ApiOperation("execute to get list books by publication date between from date and to date")
    @GetMapping("/books/recent")
    public ResponseEntity<DtoBooks> getRecentBooksByDate(@RequestParam(value = "from", required = false) String from,
                                                       @RequestParam(value = "to", required = false) String to,
                                                       @RequestParam("offset") Integer offset,
                                                       @RequestParam("limit") Integer limit) {
        DtoBooks dtoBooks;
        List<Book> books;
        if (from != null && to != null) {
            var sdf = new SimpleDateFormat("dd.MM.yyy");
            JSONObject answer = new JSONObject();
            try {
                books = bookService.getPageRecentBooksByDate(sdf.parse(from), sdf.parse(to), offset, limit).getContent();
                dtoBooks = new DtoBooks(books);
            } catch (ParseException e) {
                dtoBooks = new DtoBooks(true, "В запросе переданы некорректные данные");
            }
        } else {
            books = bookService.getPageRecentBooks(offset, limit).getContent();
            dtoBooks = new DtoBooks(books);
        }

        return ResponseEntity.ok(dtoBooks);
    }

    @GetMapping("books/author/{id}")
    public ResponseEntity<DtoBooks> getBooksByAuthor(@PathVariable String id,
                                                     @RequestParam("offset") Integer offset,
                                                     @RequestParam("limit") Integer limit) {
        DtoBooks dtoBooks;
        try {
        List<Book> books = bookService.getPageBooksByIdAuthor(Integer.parseInt(id), offset, limit).getContent();
            dtoBooks = new DtoBooks(books);
            ObjectMapper om = new ObjectMapper();
        } catch (NumberFormatException e) {
            dtoBooks = new DtoBooks(true, "В запросе переданы некорректные данные");
        }
        return ResponseEntity.ok(dtoBooks);
    }
}
