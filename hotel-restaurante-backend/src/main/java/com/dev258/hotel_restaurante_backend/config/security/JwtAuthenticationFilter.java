package com.dev258.hotel_restaurante_backend.config.security;

import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;
import com.dev258.hotel_restaurante_backend.administracao.usuario.repository.UsuarioRepository;
import com.dev258.hotel_restaurante_backend.cliente.entity.ClienteEntity;
import com.dev258.hotel_restaurante_backend.cliente.repository.ClienteRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UsuarioRepository usuarioRepository;
    private final ClienteRepository clienteRepository;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String authorization = request.getHeader("Authorization");

        if (authorization == null || !authorization.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authorization.substring(7);

        if (!jwtService.tokenValido(token)) {
            filterChain.doFilter(request, response);
            return;
        }

        String tipo = jwtService.extrairTipo(token);

        if ("CLIENTE".equalsIgnoreCase(tipo)) {
            autenticarCliente(token);
            filterChain.doFilter(request, response);
            return;
        }

        autenticarUsuario(token);

        filterChain.doFilter(request, response);
    }

    private void autenticarUsuario(String token) {
        Long idUsuario = jwtService.extrairIdUsuario(token);

        UsuarioEntity usuario = usuarioRepository.findById(idUsuario).orElse(null);

        if (usuario == null || usuario.getAtivo() == null || !usuario.getAtivo()) {
            return;
        }

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        usuario.getIdUsuario(),
                        null,
                        List.of()
                );

        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

    private void autenticarCliente(String token) {
        Long idCliente = jwtService.extrairIdCliente(token);

        ClienteEntity cliente = clienteRepository.findById(idCliente).orElse(null);

        if (cliente == null || cliente.getAtivo() == null || !cliente.getAtivo()) {
            return;
        }

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        cliente.getIdCliente(),
                        null,
                        List.of()
                );

        SecurityContextHolder.getContext().setAuthentication(authentication);
    }
}