package org.example.web.dto;

import org.json.simple.JSONObject;

import javax.validation.constraints.Digits;

public class Book {
    private Integer id;
    private String author;
    private String title;
    @Digits(integer=4,fraction=0)
    private Integer size;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {

        this.id = id;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Integer getSize() {
        return size;
    }

    public void setSize(Integer size) {
        this.size = size;
    }

    @Override
    public String toString() {
//        return "Book{" +
//                "id=" + id +
//                ", author='" + author + '\'' +
//                ", title='" + title + '\'' +
//                ", size=" + size +
//                '}';
        JSONObject jso = new JSONObject();
        jso.put("author", author);
        jso.put("title", title);
        jso.put("id", id);
        jso.put("size", size);
        return String.format("%s%s", getClass().getName(), jso.toString());
    }

    public boolean checkFields() {
        return (author != null && author.length() != 0) || (title != null && title.length() != 0) || (size != null && size != 0);
    }
}
