package com.example.demo.entity;

import io.swagger.annotations.ApiModelProperty;
import lombok.Getter;
import lombok.Setter;

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
public class Author {
    @Getter
    @Setter
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Getter
    @Setter
    @ApiModelProperty("path to author photo image")
    private String photo;

    @Getter
    @Setter
    @ApiModelProperty("mnemonical author name")
    private String slug;

    @Getter
    @Setter
    @ApiModelProperty("First name and Last name of author")
    private String name;

    @Getter
    @Setter
    @ApiModelProperty("biography and fact`s about author")
    private String description;

    @Getter
    @OneToMany(mappedBy = "author")
    //FIXME закомментированный код убираем, реализация new ArrayList так делать не верно,
    // её необходимо убрать в конструктор
//    @JoinColumn(name = "id_author", referencedColumnName = "id")
    private List<Book> authorBooks = new ArrayList<>();

    public String getLetter() {
        return name.substring(0, 1).toUpperCase();
    }

    @Override
    public String toString() {
        return "Author{" +
                "id=" + id +
                ", fio='" + name + '\'' +
                '}';
    }
}
