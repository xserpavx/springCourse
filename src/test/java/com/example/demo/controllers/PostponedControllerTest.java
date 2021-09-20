package com.example.demo.controllers;

import com.example.demo.repositories.BookRepository;
import com.example.demo.services.ControllerService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import javax.servlet.http.Cookie;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource("/application-test.properties")
class PostponedControllerTest {

    private final MockMvc mockMvc;
    private final BookRepository bookRepository;

    @Autowired
    public PostponedControllerTest(MockMvc mockMvc, BookRepository bookRepository) {
        this.mockMvc = mockMvc;
        this.bookRepository = bookRepository;
    }

    /** Тест добавления книги в отложенное
     * @throws Exception
     */
    @Test
    public void addBook2Posponed() throws Exception {
        mockMvc.perform(post("/books/changeBookStatus")
                .param("booksIds", "bookSlug")
                .param("status", ControllerService.ButtonsUI.KEPT.name()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/books/bookSlug"))
                .andExpect(cookie().value("ppCount", "1"))
                .andDo(print());

    }

    /** Тест удаления книги из отложенного
     * @throws Exception
     */
    @Test
    public void removeBookFromPostponed() throws Exception {

        String postponedBooks = "slug1/slug2";
        int ppCount = 2;

        mockMvc.perform(post("/books/changeBookStatus")
                .param("booksIds", "slug2")
                .param("status", ControllerService.ButtonsUI.UNLINK.name())
                .cookie(new Cookie("ppCount", String.format("%d", ppCount)))
                .cookie(new Cookie("postponedBooks", postponedBooks)))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("postponed"))
                .andExpect(cookie().value("ppCount", "1"))
                .andExpect(cookie().value("postponedBooks", "slug1"))
                .andDo(print());

    }

    /** Тест добавления книги в корзину
     * @throws Exception
     */
    @Test
    public void addBook2Cart() throws Exception {
        mockMvc.perform(post("/books/changeBookStatus")
                .param("booksIds", "book2Cart")
                .param("status", ControllerService.ButtonsUI.CART.name()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/books/book2Cart"))
                .andExpect(cookie().value("cartCount", "1"))
                .andDo(print());
    }

    /** Тест удаления книги из корзины
     * @throws Exception
     */
    @Test
    public void removeBookFromCart() throws Exception {

        String postponedBooks = "cartBook1/cartBook2";
        int ppCount = 2;

        mockMvc.perform(post("/books/changeBookStatus")
                .param("booksIds", "cartBook2")
                .param("status", ControllerService.ButtonsUI.UNLINK_CART.name())
                .cookie(new Cookie("ppCount", String.format("%d", ppCount)))
                .cookie(new Cookie("postponedBooks", postponedBooks)))
                .andExpect(status().isOk())
//                .andExpect(redirectedUrl("postponed"))
                .andExpect(cookie().value("cartCount", "1"))
                .andExpect(cookie().value("postponedBooks", "cartBook1"))
                .andDo(print());

    }

}