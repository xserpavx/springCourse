package com.example.demo.controllers;

import com.example.demo.entity.User;
import com.example.demo.services.ControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
public class CartController {
    private final ControllerService controllerService;

    @Autowired
    public CartController(ControllerService controllerService) {
        this.controllerService = controllerService;
    }

    @ModelAttribute("active")
    public String active() {
        return "cart";
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

    @GetMapping("books/cart")
    public String cartPage() {
        return "cart";
    }
}
