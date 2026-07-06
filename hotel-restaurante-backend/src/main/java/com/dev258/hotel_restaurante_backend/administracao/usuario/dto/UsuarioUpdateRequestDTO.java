package com.dev258.hotel_restaurante_backend.administracao.usuario.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UsuarioUpdateRequestDTO(

        @NotNull(message = "O perfil é obrigatório")
        Long idPerfil,

        Long idEstabelecimento,

        @Size(max = 120, message = "O nome deve ter no máximo 120 caracteres")
        String nome,

        @Size(max = 120, message = "O apelido deve ter no máximo 120 caracteres")
        String apelido,

        @Email(message = "Informe um email válido")
        @Size(max = 160, message = "O email deve ter no máximo 160 caracteres")
        String email,

        @Size(max = 30, message = "O telefone deve ter no máximo 30 caracteres")
        String telefone,

        Boolean ativo
) {
}