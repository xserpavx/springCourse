package com.example.demo.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
import java.util.StringJoiner;
import java.util.regex.Pattern;

/**
 * Created on 13.08.2021
 *
 * @author roland
 **/

@Service
public class ControllerService {
    @Autowired
    ControllerService() {}

    /** Удаляет из cookie список передаваемых значений. Разделитель между значениями "/"
     * @param cookieValue текущее значение cookie
     * @param removeCookieValues список удаляемых значений
     * @return новое значение cookie
     */
    public String removeCookieValue(String cookieValue, String removeCookieValues) {
        String result = cookieValue != null ? cookieValue : "";
        String[] removeValues = removeCookieValues.split("/");
        for (String remove : removeValues) {
            // Удаляем значение из начала строки
            result = result.replaceFirst("^"+remove+"/?(.*)?", "$1");
            // Удаляем значение из конца строки
            result = result.replaceFirst("^(.*)/e2$", "$1");
            // Удаляем значение из середины
            result = result.replaceFirst("^(.*)/e2/?(.*)?", "$1$2");
        }
        return result;
    }


    /** Добавляет в cookie список передаваемых значений. Разделитель между значениями "/"
     * @param cookieValue текущее значение cookie
     * @param addCookieValues список добавляемых значений
     * @return новое значение cookie
     */
    public String addCookieValue(String cookieValue, String addCookieValues) {
        var stringJoiner = new StringJoiner("/");
        stringJoiner.add(cookieValue != null ? cookieValue : "");
        String[] addValues = addCookieValues.split("/");
        for (String add : addValues) {
            var matcher = Pattern.compile("(.*?/"+add+"$)|(^"+add+"/.*?)|(.*?/"+add+"/.*?)").matcher(stringJoiner.toString());
            if (!matcher.matches()) {
                stringJoiner.add(add);
            }
        }
        return stringJoiner.toString().replaceAll("^/", "");
    }


    /** Добавляет cookie к response если
     * @param cookieName Имя cookie
     * @param cookieValue значение cookie. Если значение пустое - cookie в response не добавляется
     * @param cookiePath путь при котором доступна cookie
     * @param response HttpServletResponse в который добавляется cookie
     */
    public void addCookie(String cookieName, String cookieValue, String cookiePath, HttpServletResponse response) {
        if (!cookieValue.isEmpty()) {
            Cookie cookie = new Cookie(cookieName, cookieValue);
            cookie.setPath(cookiePath);
            response.addCookie(cookie);
        }
    }
}
