package com.example.demo.entity;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Entity
@Table(name="books")
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Getter @Setter
    private int id;
    @Getter @Setter
    private int id_author;
    @Getter @Setter
    @Transient
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

    public String getAuthor() {
        return "";
    }

    public Float getCurrentPrice() {
        return new BigDecimal(price).subtract(new BigDecimal(price).movePointLeft(2).multiply(new BigDecimal(discount))).setScale(2, RoundingMode.HALF_UP).floatValue();
    }

    public String discountString() {
        return String.format("Скидка %d%%", discount);
    }

    @Override
    public String toString() {
        return "Book{" +
                "id=" + id +
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
