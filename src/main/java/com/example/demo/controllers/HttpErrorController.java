package com.example.demo.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Created on 30.08.2021
 *
 * @author roland
 **/
@Controller
public class HttpErrorController {
    @GetMapping("/500")
    public String error500() {
            return "500";
        }
}
