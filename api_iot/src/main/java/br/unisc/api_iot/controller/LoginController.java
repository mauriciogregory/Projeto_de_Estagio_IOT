package br.unisc.api_iot.controller;

import br.unisc.api_iot.dto.DadosDoJWT;
import br.unisc.api_iot.exceptions.CustomExceptionHandlers;
import br.unisc.api_iot.model.Usuario;
import br.unisc.api_iot.repository.UsuarioRepository;
import br.unisc.api_iot.security.Dados;
import br.unisc.api_iot.security.TokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

// rota para fazer a autenticação
@RestController
@RequestMapping("/api/login")
public class LoginController {

    @Autowired
    UsuarioRepository usuarioRepository;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private TokenService tokenService;

    @PostMapping
    public ResponseEntity logar(@RequestBody Dados dados ) {
        UsernamePasswordAuthenticationToken tokenSpring = new UsernamePasswordAuthenticationToken(dados.getEmail(), dados.getPass());
        Authentication auth = authenticationManager.authenticate(tokenSpring);
        String tokenJWTGerado =tokenService.criarToken((Usuario) auth.getPrincipal());

        if(tokenJWTGerado != null) {
            return ResponseEntity.ok(new DadosDoJWT( tokenJWTGerado,"Autenticado"));
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new CustomExceptionHandlers());
    }
}
