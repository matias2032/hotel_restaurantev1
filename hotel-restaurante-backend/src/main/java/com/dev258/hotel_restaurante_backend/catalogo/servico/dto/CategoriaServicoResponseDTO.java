package com.dev258.hotel_restaurante_backend.catalogo.servico.dto;

import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.CategoriaServicoEntity;

import java.time.LocalDateTime;

public record CategoriaServicoResponseDTO(
        Long idCategoriaServico,
        String nome,
        String descricao,
        Integer ordem,
        Boolean ativo,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public CategoriaServicoResponseDTO(CategoriaServicoEntity entity) {
        this(
                entity.getIdCategoriaServico(),
                entity.getNome(),
                entity.getDescricao(),
                entity.getOrdem(),
                entity.getAtivo(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}