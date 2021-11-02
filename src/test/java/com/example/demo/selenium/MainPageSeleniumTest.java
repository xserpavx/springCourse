package com.example.demo.selenium;

import com.example.demo.entity.BookReview;
import com.example.demo.entity.User;
import com.example.demo.repositories.BookReviewRepository;
import com.example.demo.repositories.UserRepository;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Created on 21.09.2021
 *
 * @author roland
 **/
@SpringBootTest
//@IfProfileValue(name = "dev", value = "false")
public class MainPageSeleniumTest {
    private static ChromeDriver driver;
    private final UserRepository userRepository;
    private final BookReviewRepository bookReviewRepository;

    @Autowired
    public MainPageSeleniumTest(UserRepository userRepository, BookReviewRepository bookReviewRepository) {
        this.userRepository = userRepository;
        this.bookReviewRepository = bookReviewRepository;
    }

    @BeforeAll
    static void setup(){
        System.setProperty("webdriver.chrome.driver", MainPageSeleniumTest.class.getClassLoader().getResource("chromedriver.exe").getPath());

        ChromeOptions options = new ChromeOptions();
        options.addArguments("--kiosk");

        driver = new ChromeDriver(options);
        driver.manage().timeouts().pageLoadTimeout(5, TimeUnit.SECONDS);
    }

    @AfterAll
    static void tearDown(){
        driver.quit();
    }

    @Test
    public void mainPageAccessTest() throws InterruptedException {
        MainPageSelenium mainPage = new MainPageSelenium(driver);
        mainPage
                .callPage()
                .pause();

        assertTrue(driver.getPageSource().contains("BOOKSHOP"));
    }

    @Test
    public void navigationTest() throws InterruptedException {
        MainPageSelenium mainPage = new MainPageSelenium(driver);
        mainPage
                .callPage()
                .pause()
                .elementClickById("topBarGenres")
                .pause();
        assertTrue(driver.getPageSource().contains("Для детей старшего школьного возраста"));
        mainPage
                .elementClickById("topBarRecent")
                .pause();
        assertTrue(driver.getPageSource().contains("Main") && driver.getPageSource().contains("Books") && driver.getPageSource().contains("Recent"));

        mainPage
                .elementClickById("topBarPopular")
                .pause();
        assertTrue(driver.getPageSource().contains("Main") && driver.getPageSource().contains("Books") && driver.getPageSource().contains("Popular"));

        mainPage
                .elementClickById("topBarAuthors")
                .pause();
        assertTrue(driver.getPageSource().contains("Алистер Маклин") && driver.getPageSource().contains("Энн Маккефри"));
    }

    @Test
    public void bookReviewTest() throws InterruptedException {
        MainPageSelenium mainPage = new MainPageSelenium(driver);
        String phone = "1231231231";
        // Необходимо авторизоваться
        mainPage
                .callPage()
                .pause()
                .elementClickById("btnSignin")
                .pause()
                .elementClickById("signinByPhone")
                .pause()
                .elementSendKeysById("phone", phone)
                .pause()
                .elementClickById("sendauth")
                .pause()
                .elementSendKeysById("phonecode", "123123")
                .pause()
                .elementClickById("toComeInPhone")
                .pause();
        assertTrue(driver.getPageSource().contains("Выход") && driver.getPageSource().contains("123"));
        // Выполняем поиск книги, проверяем что есть результаты поиска
        mainPage
//                .callPage()
//                .pause()
                .elementSendKeysById("query", "Корол")
                .pause()
                .elementClickById("search")
                .pause();
        assertFalse(driver.getPageSource().contains("Найдено 0 книг"), "Не найдено ни одной книги! Невозможно тестировать отзывы!!!");
        // Определяем количество отзывов
        mainPage
                .elementClickById("bookLink0")
                .pause();
        int cnt = Integer.parseInt(mainPage.getElementAttribute("bookReviewsCount", "title"));
        // ставим лайики и дизлайки
        for (int i = 0; i < cnt; i++) {
            int value;
            if (i % 2 == 0) {
                // Определяем предыдущее значение
                value = Integer.parseInt(mainPage.getElementText(String.format("bookReviewDislikeCount%d", i)));
                // Ставим dislike
                mainPage
                        .elementClickById(String.format("bookReviewDislikeCount%d", i))
                        .pause();
                // Проверяем новое значение
                assertTrue(mainPage.elementTextCompare(String.format("bookReviewDislikeCount%d", i), String.format("%d", value + 1)) , String.format("Счетчик dislike-ов неверен после нажатия на кнопку в %d отзыве", i));
                // Отменяем поставленный dislike
                mainPage
                        .elementClickById(String.format("bookReviewDislikeCount%d", i))
                        .pause();
                // Проверяем новое значение
                assertTrue(mainPage.elementTextCompare(String.format("bookReviewDislikeCount%d", i), String.format("%d", value)) , String.format("Счетчик dislike-ов неверен после отмены нажатия на кнопку в %d отзыве", i));
            } else {
                value = Integer.parseInt(mainPage.getElementText(String.format("bookReviewLikeCount%d", i)));
                // Ставим like
                mainPage
                        .elementClickById(String.format("bookReviewLikeCount%d", i))
                        .pause();
                // Проверяем новое значение
                assertEquals(value + 1, Integer.parseInt(mainPage.getElementText(String.format("bookReviewLikeCount%d", i))), String.format("Счетчик like-ов неверен после нажатия на кнопку в %d отзыве", i));
                // Отменяем like
                mainPage
                        .elementClickById(String.format("bookReviewLikeCount%d", i))
                        .pause();
                // Проверяем новое значение
                assertEquals(value, Integer.parseInt(mainPage.getElementText(String.format("bookReviewLikeCount%d", i))), String.format("Счетчик like-ов неверен после отмены нажатия на кнопку в %d отзыве", i));
            }
        }
        // Оставляем отзыв о книге
        String review = "Этот отзыв оставлен при помощи системы автоматического тестирования selenium";
        mainPage
                .elementSendKeysById("review", review)
                .pause()
                .elementClickById("send_review");
        // Проверяем наличие отзыва
        assertTrue(driver.getPageSource().contains("Отзыв успешно сохранен"));
        // Удаляем отзыв
        User user = userRepository.findBookstoreUserByEmail("123@123.123");
        assertNotNull(user, "Не нашли текущего пользователя");
        BookReview bookReview = bookReviewRepository.findTop1ByIdUserOrderByIdDesc(user.getId());
        assertNotNull(bookReview, "Не нашли ни одного отзыва оставленного текущим пользователем");
        assertEquals(bookReview.getText(), review, "Не совпадает текст оставленного и удаляемого отзыва");
        bookReviewRepository.delete(bookReview);


    }
}
