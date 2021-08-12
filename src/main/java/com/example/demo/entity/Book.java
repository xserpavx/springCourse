package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
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
@Table(name = "books")
@ApiModel(description = "entity representing a book")
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Getter
    @Setter
    @ApiModelProperty("id generated by db automatically")
    private int id;
    @Getter
    @Setter
    @ApiModelProperty("foreign key to table authors")
    @Column(name="id_author")
    private int idAuthor;

    @Getter
    @Setter
    @ManyToOne
    @JoinColumn(name = "id_author", referencedColumnName = "id", insertable = false, updatable = false)
    @JsonIgnore
    private Author author;

    @Getter
    @Setter
    @ApiModelProperty("book title")
    private String title;
    @Getter
    @Setter
    @ApiModelProperty("base price of book")
    private Float price;
    @Getter
    @Setter
    @ApiModelProperty("date of publication book")
    private Date pubDate;
    @Getter
    @Setter
    @ApiModelProperty("value is true if book is bestseller")
    @JsonProperty("isBestseller")
    private Boolean bestseller;
    @Getter
    @Setter
    @ApiModelProperty("mnemonical book name")
    private String slug;
    @Getter
    @Setter
    @ApiModelProperty("path to book cover image")
    private String image;
    @Getter
    @Setter
    @ApiModelProperty("short book description")
    private String description;
    @Getter
    @Setter
    @ApiModelProperty("discount of base price of book")
    private Integer discount;

    @Getter
    @Setter
    @ApiModelProperty("index of book popular`s")
    @Column(columnDefinition = "float default 0.0")
    private float popular;

    @JsonProperty("authors")
    public String getAuthors() {
        return author.getName();
    }

    @JsonProperty("discountPrice")
    public Float getDiscountPrice() {
        return new BigDecimal(price)
                .subtract(new BigDecimal(price)
                        .multiply(new BigDecimal(discount))
                        .movePointLeft(2))
                .setScale(2, RoundingMode.HALF_UP)
                .floatValue();
    }

    @Transient
    public String discountString() {
        return String.format("Скидка %d%%", discount);
    }

    @Transient
    private String priceToString(float value) {
        return String.format("₽ %.2f", value);
    }

    @Transient
    public String stringPrice() {
        return priceToString(price);
    }

    @Transient
    public String stringDiscountPrice() {
        return priceToString(getDiscountPrice());
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
