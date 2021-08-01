package com.example.demo.controllers;


import com.example.demo.data.BookListDto;
import com.example.demo.entity.Author;
import com.example.demo.services.AuthorService;
import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created on 01.08.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/books")
public class BooksController {

    private final BookService bookService;
    private final AuthorService authorService;

    @Autowired
    public BooksController(BookService bookService, AuthorService authorService) {
        this.bookService = bookService;
        this.authorService = authorService;
    }

    @GetMapping("/authorPage/{id}")
    public String getAuthorBooksPage(@PathVariable String id, Model model) {
        try {
            Integer idAuthor = Integer.parseInt(id);
            List<Author> authors = authorService.getAuthorById(idAuthor);
            if (authors.size() != 0) {
                model.addAttribute("author", authors.get(0));
            }
            model.addAttribute("listBooks", bookService.getPageBooksByIdAuthor(idAuthor, 0, 20).getContent());
        } catch (NumberFormatException e) {

        }
        return "books/author";
    }

    @GetMapping("/author/{id}")
    @ResponseBody
    public BookListDto getBooksByTag(@PathVariable String id, @RequestParam("offset") Integer offset, @RequestParam("limit") Integer limit) {
        Integer idAuthor = Integer.parseInt(id);
        return new BookListDto(bookService.getPageBooksByIdAuthor(idAuthor, offset, limit).getContent());
    }
}
