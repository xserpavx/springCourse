package com.example.demo.security;

import lombok.Data;

/**
 * Created on 21.08.2021
 *
 * @author roland
 **/

@Data
public class RegistrationForm {
    private String name;
    private String phone;
    private String email;
    private String password;
}