package com.example.demo.controllers.rest.rto;

import lombok.Data;

/**
 * Created on 06.09.2021
 *
 * @author roland
 **/

@Data
public class RtoBookReview {
    private String bookId;
    private String text;
}
