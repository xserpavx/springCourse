package com.example.demo.entity;

import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
//TODO вместо бесконечных @Getter @Setter почему не ставите одну аннотацию @Data над классом?

@Entity
@Table(name = "authors")
@Data
public class Author {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ApiModelProperty("path to author photo image")
    private String photo;

    @ApiModelProperty("mnemonical author name")
    private String slug;

    @ApiModelProperty("First name and Last name of author")
    private String name;

    @ApiModelProperty("biography and fact`s about author")
    private String description;

    @OneToMany(mappedBy = "author")
    private List<Book> authorBooks;

    @Transient
    public String getLetter() {
        return name.substring(0, 1).toUpperCase();
    }

    private Author() {
        authorBooks = new ArrayList<>();
    }

    @Override
    public String toString() {
        return "Author{" +
                "id=" + id +
                ", fio='" + name + '\'' +
                '}';
    }
}
