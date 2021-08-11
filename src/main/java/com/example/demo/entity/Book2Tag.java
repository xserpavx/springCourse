package com.example.demo.entity;

import io.swagger.annotations.ApiModelProperty;
import lombok.Getter;
import lombok.Setter;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

/**
 * Created on 31.07.2021
 *
 * @author roland
 **/
@Entity
public class Book2Tag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Getter
    @Setter
    @ApiModelProperty("id generated by db automatically")
    private int id;

    @Getter
    @Setter
    //FIXME CamelCase
    private int id_book;

    @Getter
    @Setter
    //FIXME CamelCase
    private int id_tag;
}
