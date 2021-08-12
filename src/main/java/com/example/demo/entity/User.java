package com.example.demo.entity;

import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.persistence.*;
import java.util.Date;

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
    @GeneratedValue(strategy = GenerationType.IDENTITY)
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
}
