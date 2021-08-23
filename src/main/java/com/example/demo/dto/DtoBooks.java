package com.example.demo.dto;

import com.example.demo.entity.Book;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.List;

/**
 * Created on 24.08.2021
 *
 * @author roland
 **/
@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DtoBooks {

    private Integer count;
    private List<Book> books;

    private Boolean result;
    private String error;

    public DtoBooks(List<Book> books) {
        this.count = books.size();
        this.books = books;
        this.error = null;
        this.result = null;
    }

    public DtoBooks(Boolean result, String error) {
        this.count = null;
        this.books = null;
        this.error = error;
        this.result = result;
    }

}
