package com.dev258.hotel_restaurante_backend.cliente.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record ClienteLoginRequestDTO(

        @NotBlank(message = "A credencial é obrigatória.")
        String credencial,

        @NotBlank(message = "A senha é obrigatória.")
        String senha

) {
}