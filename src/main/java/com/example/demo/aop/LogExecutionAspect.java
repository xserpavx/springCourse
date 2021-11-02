package com.example.demo.aop;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Created on 02.11.2021
 *
 * @author roland
 **/
@Aspect
@Component
public class LogExecutionAspect {
    private final static Logger log = LoggerFactory.getLogger(LogExecutionAspect.class);

    @Pointcut(value = "within(com.example.demo.controllers.rest.*)")
    public void allMethodsOfRandomUuidServiceControllerPointcut() {
    }

    @After("allMethodsOfRandomUuidServiceControllerPointcut()")
    public void allMethodsOfRandomUuidServiceControllerAdvice(JoinPoint joinPoint) {
        log.debug(joinPoint.toShortString() + " log after");
    }
}
