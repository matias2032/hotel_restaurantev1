package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.CategoriaIngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteImagemEntity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record IngredienteResponseDTO(
        Long idIngrediente,

        CategoriaResumoDTO categoriaIngrediente,

        String nome,
        String descricao,

        BigDecimal precoAdicional,

        Boolean controlaEstoque,
        BigDecimal quantidadeEstoque,

        Boolean disponivel,
        Boolean ativo,

        String imagemPrincipalUrl,

        List<IngredienteImagemResponseDTO> imagens,

        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public IngredienteResponseDTO(IngredienteEntity entity) {
        this(
                entity.getIdIngrediente(),
                entity.getCategoriaIngrediente() != null
                        ? new CategoriaResumoDTO(entity.getCategoriaIngrediente())
                        : null,
                entity.getNome(),
                entity.getDescricao(),
                entity.getPrecoAdicional(),
                entity.getControlaEstoque(),
                entity.getQuantidadeEstoque(),
                entity.getDisponivel(),
                entity.getAtivo(),
                resolverImagemPrincipal(entity),
                entity.getImagens() != null
                        ? entity.getImagens()
                        .stream()
                        .map(IngredienteImagemResponseDTO::new)
                        .toList()
                        : List.of(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }

    private static String resolverImagemPrincipal(IngredienteEntity entity) {
        if (entity.getImagens() == null || entity.getImagens().isEmpty()) {
            return null;
        }

        return entity.getImagens()
                .stream()
                .filter(imagem -> Boolean.TRUE.equals(imagem.getPrincipal()))
                .findFirst()
                .map(IngredienteImagemEntity::getImagemUrl)
                .orElseGet(() -> entity.getImagens()
                        .stream()
                        .findFirst()
                        .map(IngredienteImagemEntity::getImagemUrl)
                        .orElse(null));
    }

    public record CategoriaResumoDTO(
            Long idCategoriaIngrediente,
            String nome
    ) {

        public CategoriaResumoDTO(CategoriaIngredienteEntity entity) {
            this(
                    entity.getIdCategoriaIngrediente(),
                    entity.getNome()
            );
        }
    }

    public record IngredienteImagemResponseDTO(
            Long idIngredienteImagem,
            String imagemUrl,
            String legenda,
            Boolean principal,
            Integer ordem,
            LocalDateTime createdAt
    ) {

        public IngredienteImagemResponseDTO(IngredienteImagemEntity entity) {
            this(
                    entity.getIdIngredienteImagem(),
                    entity.getImagemUrl(),
                    entity.getLegenda(),
                    entity.getPrincipal(),
                    entity.getOrdem(),
                    entity.getCreatedAt()
            );
        }
    }
}