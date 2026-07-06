package com.dev258.hotel_restaurante_backend.cliente.auth.service;

import com.dev258.hotel_restaurante_backend.cliente.auth.dto.ClienteLoginRequestDTO;
import com.dev258.hotel_restaurante_backend.cliente.auth.dto.ClienteLoginResponseDTO;
import com.dev258.hotel_restaurante_backend.cliente.entity.ClienteEntity;
import com.dev258.hotel_restaurante_backend.cliente.repository.ClienteRepository;
import com.dev258.hotel_restaurante_backend.config.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClienteAuthService {

    private final ClienteRepository clienteRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    @Value("${app.jwt.expiration-minutes:120}")
    private Long jwtExpirationMinutes;

    public ClienteLoginResponseDTO login(ClienteLoginRequestDTO dto) {
        String credencial = normalizarCredencial(dto.credencial());

        ClienteEntity cliente = clienteRepository
                .findFirstByEmailIgnoreCaseOrTelefoneIgnoreCase(
                        credencial,
                        credencial
                )
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Credencial ou senha incorrectos."
                ));

        if (cliente.getAtivo() == null || !cliente.getAtivo()) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Este cliente está inactivo."
            );
        }

        if (cliente.getSenhaHash() == null || cliente.getSenhaHash().isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Este cliente ainda não possui senha definida."
            );
        }

        boolean senhaConfere = passwordEncoder.matches(
                dto.senha(),
                cliente.getSenhaHash()
        );

        if (!senhaConfere) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Credencial ou senha incorrectos."
            );
        }

        String token = jwtService.gerarTokenCliente(cliente);

        return ClienteLoginResponseDTO.fromEntity(
                cliente,
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