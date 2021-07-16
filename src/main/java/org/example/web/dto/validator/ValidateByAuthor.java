package org.example.web.dto.validator;

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

public class ValidateByAuthor {

    @Getter
    @Setter
    @Size(min = 5, message = "Field author must contain at list 5 characters")
    private String author;
}
