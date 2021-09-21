package com.example.demo.controllers;

import com.example.demo.entity.User;
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

    @ModelAttribute("authUser")
    public User checkAuth() {
        return controllerService.getCurrentUser();
    }

    @ModelAttribute("ppCount")
    public int ppCount(@CookieValue(name="ppCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
    }

    @ModelAttribute("cartCount")
    public int cartCount(@CookieValue(name="cartCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
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
                                         HttpServletResponse response) {
        var switchBy = ControllerService.ButtonsUI.valueOf(status);
        String strValue;
        switch (switchBy) {
            case KEPT:
                postponedBooks = controllerService.addCookieValue(postponedBooks, slug);
                controllerService.addCookie("postponedBooks", postponedBooks, "/books", response);
                cartBooks = controllerService.removeCookieValue(cartBooks, slug);
                controllerService.addCookie("cartBooks", cartBooks, "/books", response);
                strValue = controllerService.definePostponedBooksCountCookie(postponedBooks);
                controllerService.addCookie("ppCount", strValue, "/", response);
                strValue = controllerService.definePostponedBooksCountCookie(cartBooks);
                controllerService.addCookie("cartCount", strValue, "/", response);
                return "redirect:/books/"+slug;
            case CART:
                cartBooks = controllerService.addCookieValue(cartBooks, slug);
                controllerService.addCookie("cartBooks", cartBooks, "/books", response);
                postponedBooks = controllerService.removeCookieValue(postponedBooks, slug);
                controllerService.addCookie("postponedBooks", postponedBooks, "/books", response);
                strValue = controllerService.definePostponedBooksCountCookie(cartBooks);
                controllerService.addCookie("cartCount", strValue, "/", response);
                return "redirect:/books/"+slug;
            case UNLINK_CART:
                cartBooks = controllerService.removeCookieValue(cartBooks, slug);
                controllerService.addCookie("cartBooks", cartBooks, "/books", response);
                strValue = controllerService.definePostponedBooksCountCookie(cartBooks);
                controllerService.addCookie("cartCount", strValue, "/", response);
                return "redirect:cart";
            case UNLINK:
                postponedBooks = controllerService.removeCookieValue(postponedBooks, slug);
                controllerService.addCookie("postponedBooks", postponedBooks, "/books", response);
                strValue = controllerService.definePostponedBooksCountCookie(postponedBooks);
                controllerService.addCookie("ppCount", strValue, "/", response);
                return "redirect:postponed";
            case CART_ALL:
        }

        return "/";
    }
}
