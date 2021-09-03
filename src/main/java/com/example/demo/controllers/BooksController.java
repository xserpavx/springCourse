package com.example.demo.controllers;

import com.example.demo.entity.Author;
import com.example.demo.entity.Book;
import com.example.demo.entity.User;
import com.example.demo.services.AuthorService;
import com.example.demo.services.BookService;
import com.example.demo.services.ControllerService;
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
    private final ControllerService controllerService;

    @Autowired
    public BooksController(BookService bookService, AuthorService authorService, ControllerService controllerService) {
        this.bookService = bookService;
        this.authorService = authorService;
        this.controllerService = controllerService;
    }

    @ModelAttribute("authUser")
    public User checkAuth() {
        return controllerService.getCurrentUser();
    }

    @ModelAttribute("ppCount")
    public int ppCount(@CookieValue(name="ppCount", required = false) String ppCount, @CookieValue(name="postponedBooks", required = false) String postponedBooks) {
        System.out.println(postponedBooks);
        return controllerService.getBooksCount(ppCount);
    }

    @ModelAttribute("cartCount")
    public int cartCount(@CookieValue(name="cartCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
    }

    @GetMapping("/authorPage/{slug}")
    public String getAuthorBooksPage(@PathVariable String slug, Model model) {
        List<Author> authors = authorService.getAuthorBySlug(slug);
        if (!authors.isEmpty()) {
            model.addAttribute("author", authors.get(0));
        }
        model.addAttribute("listBooks", bookService.getPageBooksBySlugAuthor(slug, 0, 20).getContent());
        return "books/author";
    }

    @GetMapping("/{slug}")
    public String getBookPage(@PathVariable String slug, Model model) {
        List<Book> books = bookService.getBookBySlug(slug);
        if (books.size() != 0) {
            model.addAttribute("book", books.get(0));
            model.addAttribute("rateCount", bookService.getRateCount(books.get(0).getId()));
            model.addAttribute("rateCountByRateValue", bookService.getRateCountByRateValue(books.get(0).getId()));
            return "books/slug";
        } else {
            return "redirect:/";
        }
    }


}
