package com.example.demo.controllers.rest;

import com.example.demo.entity.Book;
import com.example.demo.services.BookService;
import io.swagger.annotations.ApiOperation;
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
    public ResponseEntity<List<Book>> getBooksByTag(@PathVariable String id,
                                                    @RequestParam("offset") Integer offset,
                                                    @RequestParam("limit") Integer limit) {
        List<Book> books = bookService.getPageBooksByTag(id, offset, limit).getContent();
        return !books.isEmpty()
                ? ResponseEntity.ok(books)
                : new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }


    @ApiOperation("execute to get list books from bookshop by SLUG of genre")
    @GetMapping("/books/genre/{slug}")
    public ResponseEntity<List<Book>> getBooksByGenre(@PathVariable String slug, @RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
        List<Book> books = bookService.getPageBooksByGenre(slug, offset, limit).getContent();
        return !books.isEmpty()
                ? ResponseEntity.ok(books)
                : new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @ApiOperation("execute to get list recomended books from bookshop")
    @GetMapping("/books/recommended")
    public ResponseEntity<List<Book>> getRecomendedBooks(@RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
        List<Book> books = bookService.getPageAllBooks(offset, limit).getContent();
        return !books.isEmpty()
                ? ResponseEntity.ok(books)
                : new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @ApiOperation("execute to get list popular books from bookshop")
    @GetMapping("/books/popular")
    public ResponseEntity<List<Book>> getPopularBooks(@RequestParam("offset") Integer offset,
                                                      @RequestParam("limit") Integer limit) {
        List<Book> books = bookService.getPagePopularBooks(offset, limit).getContent();
        return !books.isEmpty()
                ? ResponseEntity.ok(books)
                : new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @ApiOperation("execute to get list books order by publication date desc")
    @GetMapping("/books/recent")
    public ResponseEntity<List<Book>> getRecentBooks(@RequestParam("offset") Integer offset,
                                                     @RequestParam("limit") Integer limit) {
        List<Book> books = bookService.getPageRecentBooks(offset, limit).getContent();
        return !books.isEmpty()
                ? ResponseEntity.ok(books)
                : new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @ApiOperation("execute to get list books by publication date between from date and to date")
    @GetMapping("/books/recentDate")
    public ResponseEntity<List<Book>> getRecentBooksByDate(@RequestParam(value = "from") String from,
                                                           @RequestParam(value = "to") String to,
                                                           @RequestParam("offset") Integer offset,
                                                           @RequestParam("limit") Integer limit) {
        var sdf = new SimpleDateFormat("dd.MM.yyy");
        try {
            List<Book> books = bookService.getPageRecentBooksByDate(sdf.parse(from), sdf.parse(to), offset, limit).getContent();
            return !books.isEmpty()
                    ? ResponseEntity.ok(books)
                    : new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (ParseException e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("books/author/{slug}")
    public ResponseEntity<List<Book>> getBooksByAuthor(@PathVariable String slug,
                                                       @RequestParam("offset") Integer offset,
                                                       @RequestParam("limit") Integer limit) {
        List<Book> books = bookService.getPageBooksBySlugAuthor(slug, offset, limit).getContent();
        return !books.isEmpty()
                ? ResponseEntity.ok(books)
                : new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
