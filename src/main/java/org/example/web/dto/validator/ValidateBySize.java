package org.example.web.dto.validator;

import lombok.Getter;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.validation.constraints.Digits;
import javax.validation.constraints.NotNull;

/**
 * Created on 15.07.2021
 *
 * @author roland
 **/

public class ValidateBySize {
    private final static Logger log = LoggerFactory.getLogger(ValidateBySize.class);

    @Getter
    @Setter
    @NotNull(message="Field size can not be null. Please input page count value between 1 to 9999")
    @Digits(message = "Field size must be digits and less than 4 signs", integer = 4, fraction = 0)
    private Integer size;
}
