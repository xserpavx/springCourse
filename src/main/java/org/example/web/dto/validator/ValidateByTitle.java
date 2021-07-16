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

public class ValidateByTitle {

    @Getter
    @Setter
    @Size(min = 4, message = "Field title must contain at list 4 characters")
    private String title;
}
