package com.dev258.hotel_restaurante_backend.administracao.usuario.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PerfilRequestDTO(

        @NotBlank(message = "O nome do perfil é obrigatório")
        @Size(max = 60, message = "O nome do perfil deve ter no máximo 60 caracteres")
        String nomePerfil,

        String descricao,

        Boolean status
) {
}