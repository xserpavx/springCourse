package com.example.demo.entity;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/
@Entity
@Table(name="authors")
public class Author {
    @Getter @Setter
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Getter @Setter
    private String fio;

    public String getLetter() {
        return fio.substring(0,1).toUpperCase();
    }

    @Override
    public String toString() {
        return "Author{" +
                "id=" + id +
                ", fio='" + fio + '\'' +
                '}';
    }
}
