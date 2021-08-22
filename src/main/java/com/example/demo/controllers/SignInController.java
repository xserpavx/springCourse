package com.example.demo.controllers;

import com.example.demo.security.ContactConfirmationPayLoad;
import com.example.demo.security.ContactConfirmationResponse;
import com.example.demo.security.RegistrationForm;
import com.example.demo.security.UserService;
import com.example.demo.services.ControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;

/**
 * Created on 21.07.2021
 *
 * @author roland
 **/
@Controller
public class SignInController {
    private final ControllerService controllerService;
    private final UserService userService;

    @Autowired
    public SignInController(ControllerService controllerService, UserService userService) {
        this.controllerService = controllerService;
        this.userService = userService;
    }

    @ModelAttribute("ppCount")
    public int ppCount(@CookieValue(name="ppCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
    }

    @ModelAttribute("cartCount")
    public int cartCount(@CookieValue(name="cartCount", required = false) String ppCount) {
        return controllerService.getBooksCount(ppCount);
    }

    @ModelAttribute("active")
    public String active() {
        return "signin";
    }

    @GetMapping("/signin")
    public String signinPage() {
        return "signin";
    }

    @GetMapping("/signup")
    public String signupPage(Model model) {
        model.addAttribute("regForm", new RegistrationForm());
        return "signup";
    }
    @PostMapping("/requestContactConfirmation")
    @ResponseBody
    public ContactConfirmationResponse handleRequestContactConfirmation(@RequestBody ContactConfirmationPayLoad payload) {
        ContactConfirmationResponse response = new ContactConfirmationResponse();
        response.setResult("true");
        return response;
    }

    @PostMapping("/approveContact")
    @ResponseBody
    public ContactConfirmationResponse handleRequestApproveContact(@RequestBody ContactConfirmationPayLoad payload) {
        ContactConfirmationResponse response = new ContactConfirmationResponse();
        response.setResult("true");
        return response;
    }

    @PostMapping("/reg")
    public String registrationNewUser(RegistrationForm regForm, Model model) {
        userService.registrationNewUser(regForm);
        model.addAttribute("regOk", true);
        return "signin";
    }

    @PostMapping("/login")
    @ResponseBody
    public ContactConfirmationResponse handleLogin(@RequestBody ContactConfirmationPayLoad payload, HttpServletResponse httpServletResponse) {
//        Авторизация при помощи сессий
//        return userService.login(payload);
//        Авторизация при помощи JWT
        ContactConfirmationResponse loginResponse = userService.jwtLogin(payload);
        Cookie cookie = new Cookie("token", loginResponse.getResult());
        httpServletResponse.addCookie(cookie);
        return loginResponse;
    }

    @GetMapping("/my")
    public String getMyPage() {
        return "my";
    }

    @GetMapping("/profile")
    public String getProfilePage(Model model) {
        model.addAttribute("currrentUser", userService.getCurrentUser());
        return "profile";
    }

//    @GetMapping("/logout")
//    public String logout(HttpServletRequest request) {
//        HttpSession session = request.getSession();
//        SecurityContextHolder.clearContext();
//        if (session != null) {
//            session.invalidate();
//        }
//        for (Cookie cookie : request.getCookies()) {
//            cookie.setMaxAge(0);
//        }
//        return "redirect:/";
//    }
}
