package com.example.demo.data;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/

public class Letter {
    @Getter @Setter
    private String letter;

    private HashMap<String, ArrayList<Author>> letters;

    public Letter() {
        letters = new HashMap<>();
    }

    public void addAuthor(Author author) {
        ArrayList<Author> authors = letters.get(author.getLetter());
        if (authors == null) {
            authors = new ArrayList<>();
            letters.put(author.getLetter(), authors);
        }
        authors.add(author);
    }

    public ArrayList<LetterAuthors> getLetterAuthors() {
        ArrayList<LetterAuthors> arrayLetterAuthors = new ArrayList<LetterAuthors>();
        for (String letter : letters.keySet()) {
            LetterAuthors letterAuthors = new LetterAuthors();
            letterAuthors.setLetter(letter);
            letterAuthors.setAuthors(letters.get(letter));
            arrayLetterAuthors.add(letterAuthors);
        }
        return arrayLetterAuthors;
    }


    @Override
    public String toString() {
        return "Letter{" +
                "letter='" + letter + '\'' +
                '}';
    }
}
