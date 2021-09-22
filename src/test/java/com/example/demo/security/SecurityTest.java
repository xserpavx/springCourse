package com.example.demo.security;

import com.example.demo.TestValues;
import com.example.demo.entity.User;
import com.example.demo.repositories.UserRepository;
import com.example.demo.services.UserService;
import org.hamcrest.CoreMatchers;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.anonymous;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrlPattern;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Created on 17.09.2021
 *
 * @author roland
 **/

@SpringBootTest
@AutoConfigureMockMvc
public class SecurityTest {
    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private RegistrationForm registrationForm;
    private final MockMvc mockMvc;


    @MockBean
    private UserRepository userRepositoryMock;

    @Autowired
    public SecurityTest(UserService userService, PasswordEncoder passwordEncoder, MockMvc mockMvc) {
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
        this.mockMvc = mockMvc;
    }

    @BeforeEach
    void init() {
        registrationForm = new RegistrationForm();
        registrationForm.setEmail(TestValues.newUserEmail);
        registrationForm.setName(TestValues.newUserName);
        registrationForm.setPassword(TestValues.newUserPassword);
        registrationForm.setPhone(TestValues.newUserPhone);
    }

    @AfterEach
    void finalization() {
        registrationForm = null;
    }



    /** Регистрируем нового пользователя в MOCK репозитории и проверяем корректность авторизациии созданного пользователя
    * @throws Exception
    */
    @Test
    void registerNewUser() throws Exception {
        User user = userService.registrationNewUser(registrationForm);
        assertNotNull(user);
        assertTrue(passwordEncoder.matches(registrationForm.getPassword(), user.getPassword()));
        assertTrue(CoreMatchers.is(user.getPhone()).matches(registrationForm.getPhone()));
        assertTrue(CoreMatchers.is(user.getName()).matches(registrationForm.getName()));
        assertTrue(CoreMatchers.is(user.getEmail()).matches(registrationForm.getEmail()));

        Mockito.verify(userRepositoryMock, Mockito.times(1))
                .save(Mockito.any(User.class));
    }


    /** Проверяем недоступность страницы для неавторизованного пользователя
     * @throws Exception
     */
    @Test
    void anonymousAccessTest() throws Exception {
        mockMvc.perform(get("/my").with(anonymous()))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrlPattern("**/signin"));
    }

}
