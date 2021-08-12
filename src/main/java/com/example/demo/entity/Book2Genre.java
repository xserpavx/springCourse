package com.example.demo.entity;

import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.persistence.*;

/**
 * Created on 02.08.2021
 *
 * @author roland
 **/
@Entity
@Data
public class Book2Genre {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @ApiModelProperty("id generated by db automatically")
    private int id;

    @ApiModelProperty("foreign key for table books")
    @Column(name="id_book")
    private int idBook;

    @ApiModelProperty("foreign key for table genres")
    @Column(name="id_genre")
    private int idGenre;
}
