package com.example.demo.controllers;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Created on 22.07.2021
 *
 * @author roland
 **/
@Controller
@RequestMapping("/tags")
public class TagsController {
    @GetMapping("/main")
    public String getMainPage() {
        return "/tags/index";
    }
}
