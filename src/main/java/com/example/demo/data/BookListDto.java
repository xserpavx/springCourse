package com.example.demo.data;

import com.example.demo.entity.Book;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created on 31.07.2021
 *
 * @author roland
 **/

public class BookListDto {


    private Integer count;


    private List<Book> books;

    public BookListDto(List<Book> books) {
        this.books = books;
        this.count = books.size();
    }
}
