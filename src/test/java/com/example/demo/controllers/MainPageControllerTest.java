package com.example.demo.controllers;

import com.example.demo.TestValues;
import com.example.demo.repositories.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithUserDetails;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.CoreMatchers.containsString;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestBuilders.formLogin;
import static org.springframework.security.test.web.servlet.response.SecurityMockMvcResultMatchers.authenticated;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource("/application-test.properties")
public class MainPageControllerTest {
    private final MockMvc mockMvc;
    private final UserRepository userRepository;

    @Autowired
    public MainPageControllerTest(MockMvc mockMvc, UserRepository userRepository) {
        this.mockMvc = mockMvc;
        this.userRepository = userRepository;
    }

    @Test
    @Transactional
    public void accessMainPageTest() throws Exception {
        mockMvc.perform(get("/"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(content().string(containsString("Добро пожаловать в библиотеку")));
    }

    /** Тестирование авторизации по номеру телефона
     * @throws Exception
     */
    @Test
    @Transactional
    public void loginByPhoneTest() throws Exception {
        mockMvc.perform(formLogin("/signin").user("+7 (123) 123-12-31").password("123123"))
                .andDo(print())
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/"));

    }

    /** Тестирование авторизации по адерсу электронной почты
     * @throws Exception
     */
    @Test
    @Transactional
    public void loginByEmailTest() throws Exception {
        mockMvc.perform(formLogin("/signin").user("123@123.123").password("123123"))
                .andDo(print())
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/"));

    }

    /** Тестирование отображения заголовка для авторизованного пользователя
     * @throws Exception
     */
    @Test
    @Transactional
    @WithUserDetails(TestValues.testEmail)
    public void testAuthenticatedAccessToProfilePage() throws Exception{
        mockMvc.perform(get("/profile"))
                .andDo(print())
                .andExpect(authenticated())
                .andExpect(xpath("/html/body/header/div[1]/div/div/div[3]/div/a[4]/span[1]")
                        .string(TestValues.testName));
    }

    /** Тестирование процедуры разлогинивания
     * @throws Exception
     */
    @Test
    public void testLogout() throws Exception{
        mockMvc.perform(get("/before_logout"))
                .andDo(print())
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/logout"));

        mockMvc.perform(get("/logout"))
                .andDo(print())
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/signin"));
    }

}