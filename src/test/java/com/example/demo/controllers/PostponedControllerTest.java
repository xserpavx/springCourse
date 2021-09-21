package com.example.demo.controllers;

import com.example.demo.dto.DtoChangeBookStatus;
import com.example.demo.services.ControllerService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import javax.servlet.http.Cookie;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class PostponedControllerTest {

    private final MockMvc mockMvc;

    @Autowired
    public PostponedControllerTest(MockMvc mockMvc) {
        this.mockMvc = mockMvc;
    }

    /** Тест добавления книги в отложенное
     * @throws Exception
     */
    @Test
    public void addBook2Posponed() throws Exception {
        DtoChangeBookStatus dtoChangeBookStatus = new DtoChangeBookStatus();
        dtoChangeBookStatus.setBooksIds("bookSlug");
        dtoChangeBookStatus.setStatus(ControllerService.ButtonsUI.KEPT.name());

        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(SerializationFeature.WRAP_ROOT_VALUE, false);
        ObjectWriter ow = mapper.writer().withDefaultPrettyPrinter();
        String requestJson=ow.writeValueAsString(dtoChangeBookStatus);

        mockMvc.perform(post("/books/changeBookStatus")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson))
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

        DtoChangeBookStatus dtoChangeBookStatus = new DtoChangeBookStatus();
        dtoChangeBookStatus.setBooksIds("slug2");
        dtoChangeBookStatus.setStatus(ControllerService.ButtonsUI.UNLINK.name());

        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(SerializationFeature.WRAP_ROOT_VALUE, false);
        ObjectWriter ow = mapper.writer().withDefaultPrettyPrinter();
        String requestJson=ow.writeValueAsString(dtoChangeBookStatus);

        mockMvc.perform(post("/books/changeBookStatus")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson)
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
        DtoChangeBookStatus dtoChangeBookStatus = new DtoChangeBookStatus();
        dtoChangeBookStatus.setBooksIds("book2Cart");
        dtoChangeBookStatus.setStatus(ControllerService.ButtonsUI.CART.name());

        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(SerializationFeature.WRAP_ROOT_VALUE, false);
        ObjectWriter ow = mapper.writer().withDefaultPrettyPrinter();
        String requestJson=ow.writeValueAsString(dtoChangeBookStatus);

        mockMvc.perform(post("/books/changeBookStatus")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson))
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

        String cartBooks = "cartBook1/cartBook2";
        int cartCount = 2;

        DtoChangeBookStatus dtoChangeBookStatus = new DtoChangeBookStatus();
        dtoChangeBookStatus.setBooksIds("cartBook2");
        dtoChangeBookStatus.setStatus(ControllerService.ButtonsUI.UNLINK_CART.name());

        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(SerializationFeature.WRAP_ROOT_VALUE, false);
        ObjectWriter ow = mapper.writer().withDefaultPrettyPrinter();
        String requestJson=ow.writeValueAsString(dtoChangeBookStatus);

        mockMvc.perform(post("/books/changeBookStatus")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson)
                .cookie(new Cookie("cartCount", String.format("%d", cartCount)))
                .cookie(new Cookie("cartBooks", cartBooks)))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("cart"))
                .andExpect(cookie().value("cartCount", "1"))
                .andExpect(cookie().value("cartBooks", "cartBook1"))
                .andDo(print());

    }

}