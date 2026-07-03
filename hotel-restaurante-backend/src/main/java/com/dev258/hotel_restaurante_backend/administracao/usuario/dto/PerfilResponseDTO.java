package com.dev258.hotel_restaurante_backend.administracao.usuario.dto;

import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.PerfilEntity;

import java.time.LocalDateTime;

public record PerfilResponseDTO(
        Long idPerfil,
        String nomePerfil,
        String descricao,
        Boolean status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public static PerfilResponseDTO fromEntity(PerfilEntity perfil) {
        if (perfil == null) {
            return null;
        }

        return new PerfilResponseDTO(
                perfil.getIdPerfil(),
                perfil.getNomePerfil(),
                perfil.getDescricao(),
                perfil.getStatus(),
                perfil.getCreatedAt(),
                perfil.getUpdatedAt()
        );
    }
}