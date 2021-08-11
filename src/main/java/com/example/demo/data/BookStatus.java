package com.example.demo.data;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created on 11.08.2021
 *
 * @author roland
 **/

public class BookStatus {
    @Getter @Setter
    private String status;
    @Getter @Setter
    private List<Integer> booksId;
}
