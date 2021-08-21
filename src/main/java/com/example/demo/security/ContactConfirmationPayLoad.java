package com.example.demo.security;

import lombok.Data;

/**
 * Created on 21.08.2021
 *
 * @author roland
 **/
@Data
public class ContactConfirmationPayLoad {
    private String contact;
    private String code;
}

