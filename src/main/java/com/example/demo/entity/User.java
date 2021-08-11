package com.example.demo.entity;

import io.swagger.annotations.ApiModelProperty;
import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import java.util.Date;

/**
 * Created on 04.08.2021
 *
 * @author roland
 **/

@Entity
@Table(name = "users")
public class User {
    @Getter
    @Setter
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Getter
    @Setter
    @ApiModelProperty("hash of user, use for hide ID")
    private String hash;

    @Getter
    @Setter
    @ApiModelProperty("DateTime of user registration")
    private Date regTime;

    @Getter
    @Setter
    @Column(columnDefinition = "real default 0", nullable = false)
    @ApiModelProperty("Current user`s balance, default value is 0")
    float balance;

    @Getter
    @Setter
    @ApiModelProperty("User`s name")
    private String name;
}
