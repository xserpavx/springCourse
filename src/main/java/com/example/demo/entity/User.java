package com.example.demo.entity;

import com.example.demo.services.Money;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.persistence.*;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 * Created on 04.08.2021
 *
 * @author roland
 **/

@Entity
@Data
@Table(name = "users")
public class User {
    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @SequenceGenerator( name = "usersSequence", sequenceName = "USER_SEQUENCE", allocationSize = 1, initialValue = 1000)
    @GeneratedValue( strategy = GenerationType.SEQUENCE, generator = "usersSequence")
    private int id;

    @ApiModelProperty("hash of user, use for hide ID")
    private String hash;

    @ApiModelProperty("DateTime of user registration")
    private Date regTime;

    @Column(columnDefinition = "real default 0", nullable = false)
    @ApiModelProperty("Current user`s balance, default value is 0")
    float balance;

    @ApiModelProperty("User`s name")
    private String name;

    private String email;

    private String phone;

    private String password;

    @ManyToMany
    @JoinTable(
            name = "book_review",
            joinColumns = @JoinColumn(name = "id_user"),
            inverseJoinColumns = @JoinColumn(name = "id_book"))
    List<Book> reviewedBooks;

    @Transient
    public String getBalanceString() {
        return String.format("На счете %s", Money.money2DigitsText(new BigDecimal(balance)).toLowerCase());
    }

}
