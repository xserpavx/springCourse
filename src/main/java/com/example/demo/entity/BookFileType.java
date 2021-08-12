package com.example.demo.entity;

import lombok.Data;

import javax.persistence.*;

/**
 * Created on 27.07.2021
 *
 * @author roland
 **/
@Entity
@Data
@Table(name = "book_file_types")
public class BookFileType {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)


    private Integer id;


    private String name;


    private String description;

}
