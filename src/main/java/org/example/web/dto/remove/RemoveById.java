package org.example.web.dto.remove;

import lombok.Getter;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.validation.constraints.Digits;
import javax.validation.constraints.NotNull;

/**
 * Created on 16.07.2021
 *
 * @author roland
 **/

public class RemoveById {
    private final static Logger log = LoggerFactory.getLogger(RemoveById.class);

    @Getter
    @Setter
    @NotNull(message="Field id can not be null.")
    @Digits(message = "Field id must be digits and less than 32 signs", integer = 32, fraction = 0)
    private Integer id;
}
