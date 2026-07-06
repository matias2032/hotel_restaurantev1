package com.dev258.hotel_restaurante_backend.cliente.auth.controller;

import com.dev258.hotel_restaurante_backend.cliente.auth.dto.ClienteLoginRequestDTO;
import com.dev258.hotel_restaurante_backend.cliente.auth.dto.ClienteLoginResponseDTO;
import com.dev258.hotel_restaurante_backend.cliente.auth.service.ClienteAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/clientes/auth")
@RequiredArgsConstructor
public class ClienteAuthController {

    private final ClienteAuthService clienteAuthService;

    @PostMapping("/login")
    public ClienteLoginResponseDTO login(
            @Valid @RequestBody ClienteLoginRequestDTO dto
    ) {
        return clienteAuthService.login(dto);
    }
}