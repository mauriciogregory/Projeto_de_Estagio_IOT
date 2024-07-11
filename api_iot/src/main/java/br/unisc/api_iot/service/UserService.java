package br.unisc.api_iot.service;

import br.unisc.api_iot.model.Usuario;
import br.unisc.api_iot.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    public Usuario findEmailAndQuestion(String email, String question) {
        Usuario obj_e = usuarioRepository.findUserByEmail(email);

        List<Usuario> usuario = usuarioRepository.findByQuestion(question);

        if(obj_e != null && !usuario.isEmpty() && !obj_e.getUsertype().equals("IOT")){
            return obj_e;
        }

        return null;
    }




}
