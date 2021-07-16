package org.example.web.exceptions;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created on 16.07.2021
 *
 * @author roland
 **/

public class BS_FileException extends Exception {
    private final static Logger log = LoggerFactory.getLogger(BS_FileException.class);

    private String message;

    public BS_FileException(String message) {
        this.message = message;
    }

    @Override
    public String getMessage() {
        return message;
    }
}
