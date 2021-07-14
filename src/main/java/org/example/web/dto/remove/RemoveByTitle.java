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

public class RemoveByTitle {
    private final static Logger log = LoggerFactory.getLogger(RemoveByTitle.class);

    @Getter
    @Setter
    @Size(min = 5, message = "Field title must contain at list 5 characters")
    private String title;
}
