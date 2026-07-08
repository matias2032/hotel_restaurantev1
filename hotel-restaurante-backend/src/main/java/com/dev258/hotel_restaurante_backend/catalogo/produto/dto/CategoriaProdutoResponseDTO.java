package com.dev258.hotel_restaurante_backend.catalogo.produto.dto;

import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.CategoriaProdutoEntity;

import java.time.LocalDateTime;

public record CategoriaProdutoResponseDTO(
        Long idCategoriaProduto,
        String nome,
        String descricao,
        Integer ordem,
        Boolean ativo,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public CategoriaProdutoResponseDTO(CategoriaProdutoEntity entity) {
        this(
                entity.getIdCategoriaProduto(),
                entity.getNome(),
                entity.getDescricao(),
                entity.getOrdem(),
                entity.getAtivo(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}