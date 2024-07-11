package br.unisc.api_iot.exceptions;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.file.AccessDeniedException;

@Slf4j
@ControllerAdvice
@Configuration
//@RestControllerAdvice
public class CustomExceptionHandlers  extends ResponseEntityExceptionHandler {


    @ExceptionHandler (value = {AccessDeniedException.class})
    public void handleAccessDeniedException(HttpServletRequest request, HttpServletResponse response,
                                            AccessDeniedException accessDeniedException) throws IOException {
        // 403
        response.sendError(403, "Authorization Failed : " + accessDeniedException.getMessage());
    }

    }

