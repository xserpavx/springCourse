package com.example.demo.entity;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.Date;

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
    private Float price;
    @Getter @Setter
    private Date pubDate;
    @Getter @Setter
    private Boolean bestseller;
    @Getter @Setter
    private String slug;
    @Getter @Setter
    private String image;
    @Getter @Setter
    private String description;
    @Getter @Setter
    private Integer discount;

    public Float getCurrentPrice() {
        return new BigDecimal(price).subtract(new BigDecimal(price).movePointLeft(2).multiply(new BigDecimal(discount))).floatValue();
    }

    @Override
    public String toString() {
        return "Book{" +
                "id=" + id +
                ", author='" + author + '\'' +
                ", title='" + title + '\'' +
                ", price=" + price +
                ", pubDate=" + pubDate +
                ", isBestseller=" + bestseller +
                ", slug='" + slug + '\'' +
                ", image='" + image + '\'' +
                ", description='" + description + '\'' +
                ", discount=" + discount +
                '}';
    }
}
