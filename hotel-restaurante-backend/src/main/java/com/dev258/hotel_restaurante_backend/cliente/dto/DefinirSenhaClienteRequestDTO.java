package com.dev258.hotel_restaurante_backend.cliente.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

// Usado quando o cliente ainda não possui senha definida (ex.: cadastro feito no balcão).
public record DefinirSenhaClienteRequestDTO(

        @NotBlank(message = "A nova senha é obrigatória.")
        @Size(min = 6, message = "A nova senha deve ter no mínimo 6 caracteres.")
        String novaSenha

) {}