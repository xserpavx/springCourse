package org.example.web.dto.remove;

import lombok.Getter;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.validation.constraints.Size;

/**
 * Created on 15.07.2021
 *
 * @author roland
 **/

public class RemoveByAuthor {
    private final static Logger log = LoggerFactory.getLogger(RemoveByAuthor.class);

    @Getter
    @Setter
    @Size(min = 5, message = "Field author must contain at list 5 characters")
    private String author;
}
