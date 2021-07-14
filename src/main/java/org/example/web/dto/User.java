package org.example.web.dto;

import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created on 02.07.2021
 *
 * @author roland
 **/

public class User {
    private final static Logger log = LoggerFactory.getLogger(User.class);

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    private String login;
    private String password;

    @Override
    public String toString() {
        JSONObject jso = new JSONObject();
        jso.put("login", login);
        jso.put("password", password);
        return String.format("%s%s", getClass().getName(), jso.toString());
//        return "Book{" +
//                "id=" + id +
//                ", author='" + author + '\'' +
//                ", title='" + title + '\'' +
//                ", size=" + size +
//                '}';
    }
}
