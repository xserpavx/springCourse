package org.example.web.dto;

import org.json.simple.JSONObject;

import javax.validation.constraints.*;

public class Book {

    @Positive(message = "Filed id must be integer value")
    private Integer id;

    @Size(min = 5, message = "Field author must contain at list 5 characters")
    private String author;
    @Size(min = 5, message = "Field title must contain at list 5 characters")
    private String title;

    @Min(value = 1 , message = "Field size must be more or equal than 1")
    @Max(value = 9999 , message = "Field size must be less or equal than 9999")
    @NotNull(message="Field size can not be null. Please input page count value between 1 to 9999")
    @Digits(message = "Field size must be digits and less than 4 signs", integer = 4, fraction = 0)
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
