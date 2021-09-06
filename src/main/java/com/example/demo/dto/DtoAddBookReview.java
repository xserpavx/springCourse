package com.example.demo.dto;

import lombok.Data;

/**
 * Created on 06.09.2021
 *
 * @author roland
 **/

@Data
public class DtoAddBookReview {
    private String bookId;
    private String text;
}
