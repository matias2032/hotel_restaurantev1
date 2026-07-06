package com.dev258.hotel_restaurante_backend.cliente.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ClienteRegistoRequestDTO(

        @NotBlank(message = "O nome é obrigatório.")
        @Size(max = 120, message = "O nome deve ter no máximo 120 caracteres.")
        String nome,

        @Size(max = 120, message = "O apelido deve ter no máximo 120 caracteres.")
        String apelido,

        @NotBlank(message = "O email é obrigatório.")
        @Email(message = "O email deve ser válido.")
        @Size(max = 160, message = "O email deve ter no máximo 160 caracteres.")
        String email,

        @Size(max = 30, message = "O telefone deve ter no máximo 30 caracteres.")
        String telefone,

        @NotBlank(message = "A senha é obrigatória.")
        @Size(min = 6, max = 80, message = "A senha deve ter entre 6 e 80 caracteres.")
        String senha,

        @NotBlank(message = "A confirmação de senha é obrigatória.")
        String confirmarSenha

) {}