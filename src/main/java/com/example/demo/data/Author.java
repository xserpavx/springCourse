package com.example.demo.data;

import lombok.Getter;
import lombok.Setter;

/**
 * Created on 18.07.2021
 *
 * @author roland
 **/

public class Author {
    @Getter @Setter
    private int id;
    @Getter
    private String letter;

    @Getter
    private String fio;

    public void setFio(String fio) {
        this.fio = fio;
        this.letter = fio.substring(0, 1);
    }

    @Override
    public String toString() {
        return "Author{" +
                "id=" + id +
                ", fio='" + fio + '\'' +
                '}';
    }
}
