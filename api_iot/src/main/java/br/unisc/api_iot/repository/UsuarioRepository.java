package br.unisc.api_iot.repository;

import br.unisc.api_iot.dto.UsuarioDTO;
import br.unisc.api_iot.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {

    Optional<Usuario> findByEmail(String email);
    Usuario findUserByEmail(String email);
    List<Usuario> findByQuestion(String question);
}
