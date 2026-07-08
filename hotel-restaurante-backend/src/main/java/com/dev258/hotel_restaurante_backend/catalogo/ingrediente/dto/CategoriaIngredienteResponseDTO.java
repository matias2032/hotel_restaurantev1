package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.CategoriaIngredienteEntity;

import java.time.LocalDateTime;

public record CategoriaIngredienteResponseDTO(
        Long idCategoriaIngrediente,
        String nome,
        String descricao,
        Integer ordem,
        Boolean ativo,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public CategoriaIngredienteResponseDTO(CategoriaIngredienteEntity entity) {
        this(
                entity.getIdCategoriaIngrediente(),
                entity.getNome(),
                entity.getDescricao(),
                entity.getOrdem(),
                entity.getAtivo(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}