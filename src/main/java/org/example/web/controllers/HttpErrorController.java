package org.example.web.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Created on 13.07.2021
 * Обработчик стандартных ошибок HTTP
 * @author roland
 **/

@Controller

public class HttpErrorController {
    private final static Logger log = LoggerFactory.getLogger(HttpErrorController.class);

    @GetMapping("/404")
    public String error404() {
        return "404";
    }
}
