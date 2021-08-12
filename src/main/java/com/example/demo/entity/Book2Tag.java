package com.example.demo.entity;

import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.persistence.*;

/**
 * Created on 31.07.2021
 *
 * @author roland
 **/
@Entity
@Data
public class Book2Tag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)


    @ApiModelProperty("id generated by db automatically")
    private int id;



    @Column(name="id_book")
    private int idBook;



    @Column(name="id_tag")
    private int idTag;
}
