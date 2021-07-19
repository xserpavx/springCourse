package com.example.demo.entity;

import lombok.Getter;
import lombok.Setter;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/

public class Book {

    @Getter @Setter
    private int id;
    @Getter @Setter
    private String author;
    @Getter @Setter
    private String title;
    @Getter @Setter
    private String priceOld;
    @Getter @Setter
    private String price;

    @Override
    public String toString() {
        return "Book{" +
                "id=" + id +
                ", author='" + author + '\'' +
                ", title='" + title + '\'' +
                ", priceOld='" + priceOld + '\'' +
                ", price='" + price + '\'' +
                '}';
    }
}
