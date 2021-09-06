package com.example.demo.controllers.rest;

import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Created on 11.08.2021
 *
 * @author roland
 **/
@RestController
@RequestMapping("/api/auth")
public class AuthRestApiController {

    @GetMapping("/refreshtoken")
    public void refreshToken(@CookieValue(name="token") String accessToken) {
        System.out.println(accessToken);
    }
}
