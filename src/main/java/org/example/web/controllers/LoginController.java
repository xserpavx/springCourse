package org.example.web.controllers;

import org.apache.log4j.Logger;
import org.example.app.services.LoginService;
import org.example.web.dto.LoginForm;
import org.example.web.exceptions.BS_LoginException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.security.auth.login.LoginException;

@Controller
@RequestMapping(value = "/login")
public class LoginController {

    private final Logger logger = Logger.getLogger(LoginController.class);
    private final LoginService loginService;

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    private String message = "";

    @Autowired
    public LoginController(LoginService loginService) {
        this.loginService = loginService;
    }

    @GetMapping
    public String login(Model model) {
        logger.info("GET /login returns login_page.html");
        model.addAttribute("loginForm", new LoginForm());
        model.addAttribute("errorMessage", this.getMessage());
        return "login_page";
    }

    @PostMapping("/auth")
    public String authenticate(LoginForm loginFrom) throws BS_LoginException {
        if (loginService.authenticate(loginFrom)) {
            logger.info("login OK redirect to book shelf");
            setMessage("");
            return "redirect:/books/shelf";
        } else {
            logger.info("login FAIL redirect back to login");
            throw new BS_LoginException("Invalid username or password!");
//            return "redirect:/login";
        }
    }

    @PostMapping("/reg")
    public String registerNewUser(LoginForm loginForm) {
        loginService.addNewUser(loginForm);
        return "redirect:/login";
    }

    @ExceptionHandler(BS_LoginException.class)
    public String handleError(Model model, BS_LoginException exception) {
        setMessage(exception.getMessage());
        return "redirect:/login";
    }
}
