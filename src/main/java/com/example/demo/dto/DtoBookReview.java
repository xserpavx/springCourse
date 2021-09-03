package com.example.demo.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

/**
 * Created on 03.09.2021
 *
 * @author roland
 **/
@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DtoBookReview {
    private Boolean result;
    private String error;

    public DtoBookReview() {
        result = true;
        error = null;
    }

    public DtoBookReview(String error) {
        result = false;
        this.error = error;
    }
}
