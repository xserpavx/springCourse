package org.example.web.dto;

import lombok.Getter;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.validation.constraints.Digits;
import javax.validation.constraints.Positive;

/**
 * Created on 14.07.2021
 *
 * @author roland
 **/

public class RemoveBook {
    private final static Logger log = LoggerFactory.getLogger(RemoveBook.class);

    @Getter @Setter
    @Positive(message = "Filed id must be integer value")
    private Integer id;
    @Getter @Setter
    private Integer size;
    @Getter @Setter
    private String author;
    @Getter @Setter
    private String title;
}
