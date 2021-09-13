package com.example.demo.services;

import com.example.demo.entity.Author;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class AuthorServiceTest {
    private final AuthorService authorService;

    @Autowired
    public AuthorServiceTest(AuthorService authorService) {
        this.authorService = authorService;
    }

    @Test
    public void getAuthorsTest() {
        // Получаем список авторов сгруппированных по первой букве имени
        Map<String, List<Author>> authors = authorService.getAuthors();
        // Проверяем что список не пуст
        assertEquals(true,  authors != null, "List authors is null!");

        // Проверяем что для каждой буквы в списке есть
        for (Map.Entry<String, List<Author>> entry : authors.entrySet()) {
            assertEquals(false, entry.getValue().isEmpty(), String.format("List authors by letter \"%s\" is empty!", entry.getKey()));
        }
    }
}