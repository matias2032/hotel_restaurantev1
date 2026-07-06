package com.dev258.hotel_restaurante_backend.administracao.auth.controller;

import com.dev258.hotel_restaurante_backend.administracao.auth.dto.LoginRequestDTO;
import com.dev258.hotel_restaurante_backend.administracao.auth.dto.LoginResponseDTO;
import com.dev258.hotel_restaurante_backend.administracao.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public LoginResponseDTO login(@Valid @RequestBody LoginRequestDTO dto) {
        return authService.login(dto);
    }
}