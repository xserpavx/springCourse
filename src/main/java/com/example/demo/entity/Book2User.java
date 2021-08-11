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
public class Book2User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Getter
    @Setter
    @ApiModelProperty("id generated by db automatically")
    private int id;

    @Getter
    @Setter
    @ApiModelProperty("link createion time")
    private Date time;

    @Getter
    @Setter
    @ApiModelProperty("foreign key on table book_user_types")
    @Column(name="id_type")
    private Integer idType;

    @Getter
    @Setter
    @ApiModelProperty("foreign key on table books")
    @Column(name="id_book")
    private Integer idBook;

    @Getter
    @Setter
    @ApiModelProperty("foreign key on table users")
    @Column(name="id_user")
    private Integer idUser;

}
