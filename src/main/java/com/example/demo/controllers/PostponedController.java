package com.example.demo.controllers;

import com.example.demo.repositories.BookRepository;
import com.example.demo.services.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
import java.util.StringJoiner;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
public class PostponedController {
    private final BookService bookService;

    @Autowired
    public PostponedController(BookService bookService) {
        this.bookService = bookService;
    }

    @ModelAttribute("active")
    public String active() {
        return "postponed";
    }

    @GetMapping("books/postponed")
    public String postponedPage(@CookieValue(name="postponedBooks", required = false) String postponedBooks, Model model) {
        if (postponedBooks != null && !postponedBooks.isEmpty()) {
            String[] pb = postponedBooks.replaceAll("^/", "").replaceAll("/$", "").split("/");
            model.addAttribute("postponed", bookService.getBooksBySlug(pb));
        }
        return "postponed";
    }

    @PostMapping(value="/books/changeBookStatus")
    public String changeBookStatus(@RequestParam(value = "booksIds") String slug, @RequestParam(value = "status") String status,
                                   @CookieValue(name="postponedBooks", required = false) String postponedBooks,
                                   @CookieValue(name="cartBooks", required = false) String cartBooks,
                                   HttpServletResponse response, Model model
    ) {
        StringJoiner stringJoiner = new StringJoiner("/");
        BookRepository.BookUserTypes switchBy = BookRepository.BookUserTypes.valueOf(status);
        String cookieName = "";
        switch (switchBy) {
            case KEPT:
                if (postponedBooks == null || postponedBooks.length() == 0) {
                    stringJoiner.add(slug);
                } else if (!postponedBooks.contains(slug)) {
                    stringJoiner.add(postponedBooks).add(slug);
                }
                model.addAttribute("isPostponedEmpty", false);
                cookieName = "postponedBooks";
                break;
            case CART:
                cookieName = "cartBooks";
                break;
        }

        if (!stringJoiner.toString().isEmpty()) {
            Cookie cookie = new Cookie(cookieName, stringJoiner.toString());
            cookie.setPath("/books");
            response.addCookie(cookie);
        }
        return "redirect:/books/"+slug;
    }
}
