package com.example.demo.data;

import lombok.Getter;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/

public class Book {
    private final static Logger log = LoggerFactory.getLogger(Book.class);

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
