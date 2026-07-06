package com.dev258.hotel_restaurante_backend.cliente.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ClienteCreateRequestDTO(

        @NotNull(message = "O perfil de cliente é obrigatório.")
        Long idPerfilCliente,

        @NotBlank(message = "O nome é obrigatório.")
        @Size(max = 120, message = "O nome deve ter no máximo 120 caracteres.")
        String nome,

        @Size(max = 120, message = "O apelido deve ter no máximo 120 caracteres.")
        String apelido,

        @Email(message = "O email deve ser válido.")
        @Size(max = 160, message = "O email deve ter no máximo 160 caracteres.")
        String email,

        @Size(max = 30, message = "O telefone deve ter no máximo 30 caracteres.")
        String telefone,

        @Size(max = 30, message = "O NUIT deve ter no máximo 30 caracteres.")
        String nuit
) {}