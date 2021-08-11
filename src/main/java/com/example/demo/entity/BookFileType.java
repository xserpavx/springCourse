package com.example.demo.entity;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;

/**
 * Created on 27.07.2021
 *
 * @author roland
 **/
@Entity
@Table(name = "book_file_types")
public class BookFileType {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Getter
    @Setter
    private Integer id;
    @Getter
    @Setter
    private String name;
    @Getter
    @Setter
    private String description;

}
