package br.unisc.api_iot.controller;


import br.unisc.api_iot.dto.RecoverUserPassDTO;
import br.unisc.api_iot.model.Usuario;
import br.unisc.api_iot.repository.UsuarioRepository;
import br.unisc.api_iot.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Locale;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class CadastroController {

    @Autowired
    UsuarioRepository usuarioRepository;

    @Autowired
    private UserService userService;

    @PostMapping("/cadastro")
    public ResponseEntity cadastroUsuario(@Valid @RequestBody Usuario user){

        String novoEmail = user.getEmail();
        Optional<Usuario> emailExiste= this.usuarioRepository.findByEmail(novoEmail);

        if(!emailExiste.isPresent()){
            String pass = user.getPass();
            BCryptPasswordEncoder newPass = new BCryptPasswordEncoder();
            String passEncodedHash = newPass.encode(pass);
            user.setPass(passEncodedHash);
            usuarioRepository.save(user);
        } else {
            return ResponseEntity.status(HttpStatus.FOUND).body("Usuário já existe!");
        }
        return ResponseEntity.status(201).body(user);
    }

    @PatchMapping("/recover")
    public ResponseEntity update(@Valid @RequestBody RecoverUserPassDTO user){

        Usuario usuario = userService.findEmailAndQuestion(user.getEmail(), user.getQuestion());

        if(usuario != null && usuario.getUsertype().toUpperCase().equals("USER")){
            String pass = user.getPass();
            BCryptPasswordEncoder newPass = new BCryptPasswordEncoder();
            String passEncodedHash = newPass.encode(pass);
            usuario.setPass(passEncodedHash);
            usuarioRepository.save(usuario);
            return  ResponseEntity.status(200).body("Atualizado com sucesso!");
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Usuário não encontrado/operação não permitida!");
    }

}
