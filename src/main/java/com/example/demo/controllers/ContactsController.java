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
public class ContactsController {
    private final ControllerService controllerService;

    @Autowired
    public ContactsController(ControllerService controllerService) {
        this.controllerService = controllerService;
    }

    @ModelAttribute("authUser")
    public User checkAuth() {
        return controllerService.addCurrentUser2Model();
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
        return "contacts";
    }

    @GetMapping("/contacts")
    public String contactsPage() {
        return "contacts";
    }
}
