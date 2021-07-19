package com.example.demo.entity;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/

public class LetterAuthors {
    @Getter @Setter
    private String letter;
    @Getter @Setter
    private ArrayList<Author> authors;
}
