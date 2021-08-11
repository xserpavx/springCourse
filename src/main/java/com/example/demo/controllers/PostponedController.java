package com.example.demo.controllers;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
public class PostponedController {
    @ModelAttribute("active")
    public String active() {
        return "postponed";
    }

    @GetMapping("/postponed")
    public String postponedPage() {
        return "postponed";
    }

    @PostMapping(value="/changeBookStatus")
    public String changeBookStatus(@RequestParam(value = "booksIds") Integer  bookId, @RequestParam(value = "status") String status) {
        System.out.println(status);
        return "";
//        System.out.println(bookStatus.getStatus());
//        System.out.println(bookStatus.getBooksId());
    }
}
