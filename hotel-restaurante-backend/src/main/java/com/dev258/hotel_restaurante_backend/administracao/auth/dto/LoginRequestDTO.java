package com.dev258.hotel_restaurante_backend.administracao.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record LoginRequestDTO(

        @NotBlank(message = "A credencial é obrigatória")
        String credencial,

        @NotBlank(message = "A senha é obrigatória")
        String senha
) {
}