package br.unisc.api_iot.dto;

import lombok.Data;

@Data
public class RecoverUserPassDTO {
    private String email;
    private String pass;
    private String question;
}
