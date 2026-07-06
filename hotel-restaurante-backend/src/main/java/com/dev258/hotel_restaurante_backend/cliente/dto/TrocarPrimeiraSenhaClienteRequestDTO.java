package com.dev258.hotel_restaurante_backend.cliente.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record TrocarPrimeiraSenhaClienteRequestDTO(

        @NotBlank(message = "A nova senha é obrigatória")
        @Size(min = 6, max = 80, message = "A nova senha deve ter entre 6 e 80 caracteres")
        String novaSenha
) {
}