package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.CategoriaIngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteCategoriaEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteImagemEntity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

public record IngredienteResponseDTO(
        Long idIngrediente,

        List<CategoriaResumoDTO> categoriasIngrediente,

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
                resolverCategorias(entity),
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

    private static List<CategoriaResumoDTO> resolverCategorias(
            IngredienteEntity entity
    ) {
        if (entity.getCategorias() == null || entity.getCategorias().isEmpty()) {
            return List.of();
        }

        return entity.getCategorias()
                .stream()
                .sorted(
                        Comparator
                                .comparing(
                                        IngredienteCategoriaEntity::getPrincipal,
                                        Comparator.nullsLast(Comparator.reverseOrder())
                                )
                                .thenComparing(
                                        IngredienteCategoriaEntity::getOrdem,
                                        Comparator.nullsLast(Integer::compareTo)
                                )
                                .thenComparing(categoria -> categoria
                                        .getCategoriaIngrediente()
                                        .getNome()
                                )
                )
                .map(IngredienteCategoriaEntity::getCategoriaIngrediente)
                .map(CategoriaResumoDTO::new)
                .toList();
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
            String nome,
            Boolean principal,
            Integer ordem
    ) {

        public CategoriaResumoDTO(IngredienteCategoriaEntity entity) {
            this(
                    entity.getCategoriaIngrediente().getIdCategoriaIngrediente(),
                    entity.getCategoriaIngrediente().getNome(),
                    entity.getPrincipal(),
                    entity.getOrdem()
            );
        }

        public CategoriaResumoDTO(CategoriaIngredienteEntity entity) {
            this(
                    entity.getIdCategoriaIngrediente(),
                    entity.getNome(),
                    false,
                    0
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