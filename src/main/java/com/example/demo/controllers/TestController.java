package com.example.demo.controllers;

import com.example.demo.data.BookStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.ModelAndView;

/**
 * Created on 14.08.2021
 *
 * @author roland
 **/
@Controller
public class TestController {
    @PostMapping("/test22")
    public ModelAndView test(BookStatus bookStatus, ModelMap model) {
        bookStatus.setStatus(String.format("%d", Math.round(Math.random()*100)));
        model.addAttribute("bookStatus", bookStatus);
        return new ModelAndView("redirect:/test22", model);
    }

    @GetMapping("/test22")
    public String test22(BookStatus bookStatus, ModelMap model) {
        model.addAttribute("bookStatus", bookStatus);
        return "test";
    }

    @GetMapping("/test")
    public String test2(BookStatus bookStatus, Model model) {
        model.addAttribute("bookStatus", bookStatus);
        return "test";
    }

}
