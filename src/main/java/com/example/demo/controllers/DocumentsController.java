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
@RequestMapping("/documents")
public class DocumentsController {
    @ModelAttribute("active")
    public String active() {
        return "documents";
    }

    @GetMapping("/main")
    public String documentsPage() {
        return "documents/index";
    }
}
