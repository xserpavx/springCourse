package com.example.demo.entity;

import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.persistence.*;
import java.util.List;

/**
 * Created on 31.07.2021
 *
 * @author roland
 **/
@Entity
@Data
@Table(name="tags")
public class Tag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @ApiModelProperty("id generated by db automatically")
    private int id;

    private String tagName;

    @OneToMany
    @JoinTable(
            name = "book2tag",
            joinColumns = @JoinColumn(name = "id_tag"),
            inverseJoinColumns = @JoinColumn(name = "id_book"))
    List<Book> taggedBooks;

    @Transient
    public String tagClassName(int classLength) {
        switch (taggedBooks.size() / classLength) {
            case 0: return "Tag_xs";
            case 1: return "Tag_sm";
            case 2: return "Tag_md";
            default: return "Tag_lg";
        }
    }

    @Transient
    public String tagHidden() {
        return taggedBooks.isEmpty() ? "display:none" : "";
    }
}
