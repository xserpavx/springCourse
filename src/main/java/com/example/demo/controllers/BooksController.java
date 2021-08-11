package com.example.demo.controllers;

import com.example.demo.entity.Author;
import com.example.demo.services.AuthorService;
import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

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

    @GetMapping("/authorPage/{slug}")
    public String getAuthorBooksPage(@PathVariable String slug, Model model) {
        List<Author> authors = authorService.getAuthorBySlug(slug);
        //FIXME используйте лучше проверку коллекции isEmpty
        if (authors.size() != 0) {
            model.addAttribute("author", authors.get(0));
        }
        model.addAttribute("listBooks", bookService.getPageBooksBySlugAuthor(slug, 0, 20).getContent());
        return "books/author";
    }


}
