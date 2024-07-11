package br.unisc.api_iot.security;

import br.unisc.api_iot.model.Usuario;
import br.unisc.api_iot.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;

@Component
public class FilterSecurity extends OncePerRequestFilter {

    @Autowired
    TokenService tokenService;

    @Autowired
    UsuarioRepository usuarioRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {

        String token = recuperarTokenDaApi(request);

        if(token != null) {
            String sub = tokenService.recuperarToken(token);
            Optional<Usuario> usuario = usuarioRepository.findByEmail(sub);
            UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(usuario, null, usuario.get().getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(auth);
        }

        filterChain.doFilter(request, response); // encaminha para o prox filtro
    }

    private String recuperarTokenDaApi(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");

        if(authorization != null) {
            return authorization.replace("Bearer ", "");
        }

        return null;
    }
}

