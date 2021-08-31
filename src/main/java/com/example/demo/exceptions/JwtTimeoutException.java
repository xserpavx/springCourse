package com.example.demo.exceptions;

/**
 * Created on 30.08.2021
 *
 * @author roland
 **/

public class JwtTimeoutException extends Exception {

    private String message;

    public JwtTimeoutException(String message) {
        this.message = message;
    }

    @Override
    public String getMessage() {
        return message;
    }
}
