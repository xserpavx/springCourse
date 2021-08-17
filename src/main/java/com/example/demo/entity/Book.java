package com.example.demo.entity;

import com.example.demo.services.ControllerService;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.persistence.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import java.util.List;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Entity
@Data
@Table(name = "books")
@ApiModel(description = "entity representing a book")
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @ApiModelProperty("id generated by db automatically")
    private int id;
    @ApiModelProperty("foreign key to table authors")
    @Column(name="id_author")
    private int idAuthor;

    @ManyToOne
    @JoinColumn(name = "id_author", referencedColumnName = "id", insertable = false, updatable = false)
    @JsonIgnore
    private Author author;

    @ApiModelProperty("book title")
    private String title;
    @ApiModelProperty("base price of book")
    private Float price;
    @ApiModelProperty("date of publication book")
    private Date pubDate;
    @ApiModelProperty("value is true if book is bestseller")
    @JsonProperty("isBestseller")
    private Boolean bestseller;
    @ApiModelProperty("mnemonical book name")
    private String slug;
    @ApiModelProperty("path to book cover image")
    private String image;
    @ApiModelProperty("short book description")
    private String description;
    @ApiModelProperty("discount of base price of book")
    private Integer discount;

    @ApiModelProperty("index of book popular`s")
    @Column(columnDefinition = "float default 0.0")
    private float popular;

    @ApiModelProperty("average users rating of book")
    @Column(columnDefinition = "int default 0")
    private int rating;

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

    @ManyToMany(mappedBy = "taggedBooks")
    List<Tag> bookTags;

    @OneToMany
    @JoinTable(
            name = "book_review",
            joinColumns = @JoinColumn(name = "id_book"),
            inverseJoinColumns = @JoinColumn(name = "id"))
    List<BookReview> bookReviews;

    @Transient
    public String getReviewEnding() {
        return ControllerService.getEnding(bookReviews.size(), "", "а", "ов");
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
