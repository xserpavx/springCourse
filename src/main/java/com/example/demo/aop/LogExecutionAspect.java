package com.example.demo.aop;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
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
    public void executionLogPointcut() {
    }

    @Pointcut(value = "@annotation(com.example.demo.aop.annotations.LogExecution)")
    public void executionLogAnnotationPointcut() {
    }

    @Around("executionLogPointcut() || executionLogAnnotationPointcut()")
    public Object logRestMethodExecutionAdvice(ProceedingJoinPoint proceedingJoinPoint) {
        Object returnValue = null;
        try {
            returnValue = proceedingJoinPoint.proceed();
        } catch (Throwable throwable) {
            throwable.printStackTrace();
        }
        log.info(proceedingJoinPoint.toString() + " success");
        return returnValue;
    }

}
