package com.dev258.hotel_restaurante_backend.cliente.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PerfilClienteRequestDTO(

        @NotBlank(message = "O nome do perfil de cliente é obrigatório.")
        @Size(max = 120, message = "O nome do perfil de cliente deve ter no máximo 120 caracteres.")
        String nomePerfilCliente

) {}