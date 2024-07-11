package br.unisc.api_iot.security;

import br.unisc.api_iot.model.Usuario;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTCreationException;
import com.auth0.jwt.exceptions.JWTVerificationException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Date;

@Service
public class TokenService {

    @Value("${security.token.secretkey}")
    private String secretkey;

    public String criarToken(Usuario usuario) {
        try {
            Algorithm algoritmo = Algorithm.HMAC256(secretkey);

            return JWT.create()
                    .withIssuer("IoT unisc")
                    .withSubject(usuario.getEmail())
                    .withExpiresAt(Date.from(LocalDateTime.now().plusHours(24).toInstant(ZoneOffset.of("-03:00"))))
                    .sign(algoritmo);
        } catch (JWTCreationException exception) {
            throw new RuntimeException("Erro ao criar o token", exception);
        }

    }

    public String recuperarToken(String token) {
        try{
            Algorithm algoritmo = Algorithm.HMAC256(secretkey);

            return JWT.require(algoritmo)
                    .withIssuer("IoT unisc")
                    .build()
                    .verify(token)
                    .getSubject();

        } catch (JWTVerificationException e){
            throw new RuntimeException("Token inválido ou expirado.");
        }
    }

}
