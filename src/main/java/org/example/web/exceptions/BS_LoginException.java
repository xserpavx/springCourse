package org.example.web.exceptions;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.ExceptionHandler;

/**
 * Created on 13.07.2021
 *
 * @author roland
 **/

public class BS_LoginException extends Exception {
    private final static Logger log = LoggerFactory.getLogger(BS_LoginException.class);

    private String message;

    public BS_LoginException(String message) {
        this.message = message;
    }

    @Override
    public String getMessage() {
        return message;
    }

}
