package com.dev258.hotel_restaurante_backend.administracao.auth.service;

import com.dev258.hotel_restaurante_backend.administracao.auth.dto.LoginRequestDTO;
import com.dev258.hotel_restaurante_backend.administracao.auth.dto.LoginResponseDTO;
import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;
import com.dev258.hotel_restaurante_backend.administracao.usuario.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.dev258.hotel_restaurante_backend.config.security.JwtService;
import org.springframework.beans.factory.annotation.Value;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final UsuarioRepository usuarioRepository;

    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    private final JwtService jwtService;

@Value("${app.jwt.expiration-minutes:120}")
private Long jwtExpirationMinutes;

    public LoginResponseDTO login(LoginRequestDTO dto) {
        String credencial = normalizarCredencial(dto.credencial());

        UsuarioEntity usuario = usuarioRepository
                .findFirstByEmailIgnoreCaseOrTelefoneIgnoreCaseOrApelidoIgnoreCase(
                        credencial,
                        credencial,
                        credencial
                )
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Credencial ou senha incorrectos."
                ));

        if (usuario.getAtivo() == null || !usuario.getAtivo()) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Este usuário está inactivo."
            );
        }

        boolean senhaConfere = passwordEncoder.matches(
                dto.senha(),
                usuario.getSenhaHash()
        );

        if (!senhaConfere) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Credencial ou senha incorrectos."
            );
        }
String token = jwtService.gerarToken(usuario);

return LoginResponseDTO.fromEntity(
        usuario,
        token,
        jwtExpirationMinutes
);
    }

    private String normalizarCredencial(String valor) {
        if (valor == null) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "A credencial é obrigatória."
            );
        }

        String texto = valor.trim();

        if (texto.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "A credencial é obrigatória."
            );
        }

        return texto;
    }
}