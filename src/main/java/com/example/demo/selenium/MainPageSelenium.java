package com.example.demo.selenium;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;

/**
 * Created on 21.09.2021
 *
 * @author roland
 **/

public class MainPageSelenium {

    private String url = "http://localhost:8082/";
    private ChromeDriver driver;

    public MainPageSelenium(ChromeDriver driver) {
        this.driver = driver;
    }

    public MainPageSelenium callPage() {
        driver.get(url);
        return this;
    }

    public MainPageSelenium pause() throws InterruptedException {
        Thread.sleep(2000);
        return this;
    }

    public MainPageSelenium elementClickById(String id) {
        WebElement element = driver.findElement(By.id(id));
        element.click();
        return this;
    }

    public MainPageSelenium elementSendKeysById(String id, String token) {
        WebElement element = driver.findElement(By.id(id));
        element.sendKeys(token);
        return this;
    }

    public boolean elementTextCompare(String id, String text) {
        WebElement element = driver.findElement(By.id(id));
        return element.getText().compareTo(text) == 0;
    }

    public String getElementText(String id) {
        WebElement element = driver.findElement(By.id(id));
        return element.getText();
    }

    public String getElementAttribute(String id, String attribute) {
        WebElement element = driver.findElement(By.id(id));
        return element.getAttribute(attribute);
    }
}
