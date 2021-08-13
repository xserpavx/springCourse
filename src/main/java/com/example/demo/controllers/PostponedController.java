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
import java.util.regex.Pattern;

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
            model.addAttribute("slugs4BuyAll", postponedBooks);
        }
        return "postponed";
    }

    /** Удаляет из куки список передаваемых значений
     * @param cookieValue текущее значение куки
     * @param removeCookieValues список удаляемых значений
     * @return новое значение куки
     */
    private String removeCookieValue(String cookieValue, String removeCookieValues) {
        String result = cookieValue != null ? cookieValue : "";
        String[] removeValues = removeCookieValues.split("/");
        for (String remove : removeValues) {
            // Удаляем значение из начала строки
            result = result.replaceFirst("^"+remove+"/?(.*)?", "$1");
            // Удаляем значение из конца строки
            result = result.replaceFirst("^(.*)/e2$", "$1");
            // Удаляем значение из середины
            result = result.replaceFirst("^(.*)/e2/?(.*)?", "$1$2");
        }
        return result;
    }

    private String addCookieValue(String cookieValue, String addCookieValues) {
        var stringJoiner = new StringJoiner("/");
        stringJoiner.add(cookieValue != null ? cookieValue : "");
        String[] addValues = addCookieValues.split("/");
        for (String add : addValues) {
            var matcher = Pattern.compile("(.*?/"+add+"$)|(^"+add+"/.*?)|(.*?/"+add+"/.*?)").matcher(stringJoiner.toString());
            if (!matcher.matches()) {
                stringJoiner.add(add);
            }
        }
        return stringJoiner.toString().replaceAll("^/", "");
    }

    private void addCookie(String cookieName, String cookieValue, String cookiePath, HttpServletResponse response) {
        if (!cookieValue.isEmpty()) {
            Cookie cookie = new Cookie(cookieName, cookieValue);
            cookie.setPath(cookiePath);
            response.addCookie(cookie);
        }
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
                addCookie("postponedBooks",  addCookieValue(postponedBooks, slug), "/books", response);
                addCookie("cartBooks",  removeCookieValue(cartBooks, slug), "/books", response);
                return "redirect:/books/"+slug;
            case CART:
                // При добавлении книг в cookie корзины - необходимо убрать их из cookie отложено
                cookieName = "cartBooks";
                break;
        }

        return result;
    }
}
