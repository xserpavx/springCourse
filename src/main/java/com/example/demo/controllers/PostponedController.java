package com.example.demo.controllers;

import com.example.demo.repositories.BookRepository;
import com.example.demo.services.BookService;
import com.example.demo.services.ControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
public class PostponedController {
    private final BookService bookService;
    private final ControllerService controllerService;

    @Autowired
    public PostponedController(BookService bookService, ControllerService controllerService) {
        this.bookService = bookService;
        this.controllerService = controllerService;
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
            model.addAttribute("slugs4BuyAll", postponedBooks);
        }
        return "postponed";
    }

    @PostMapping(value="/books/changeBookStatus")
    public String changeBookStatus(@RequestParam(value = "booksIds") String slug, @RequestParam(value = "status") String status,
                                   @CookieValue(name="postponedBooks", required = false) String postponedBooks,
                                   @CookieValue(name="cartBooks", required = false) String cartBooks,
                                   HttpServletResponse response, Model model
    ) {
        BookRepository.BookUserTypes switchBy = BookRepository.BookUserTypes.valueOf(status);
        String cookieName = "";
        String result = "";
        switch (switchBy) {
            case KEPT:
                controllerService.addCookie("postponedBooks",  controllerService.addCookieValue(postponedBooks, slug), "/books", response);
                controllerService.addCookie("cartBooks",  controllerService.removeCookieValue(cartBooks, slug), "/books", response);
                return "redirect:/books/"+slug;
            case CART:
                // При добавлении книг в cookie корзины - необходимо убрать их из cookie отложено
                cookieName = "cartBooks";
                break;
        }

        return result;
    }
}
