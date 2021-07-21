package com.example.demo.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/books")
public class RecentController {

    @ModelAttribute("active")
    public String active() {
        return "recent";
    }

    @GetMapping("/recent")
    public String recentPage() {
        return "/books/recent";
    }
}
