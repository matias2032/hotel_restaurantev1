package com.dev258.hotel_restaurante_backend.catalogo.servico.dto;

import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.CategoriaServicoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoImagemEntity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record ServicoResponseDTO(
        Long idServico,

        CategoriaResumoDTO categoriaServico,

        String nome,
        String descricao,

        BigDecimal preco,

        String imagemPrincipalUrl,

        Boolean disponivel,
        Boolean destaque,
        Boolean ativo,

        List<ServicoImagemResponseDTO> imagens,

        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public ServicoResponseDTO(ServicoEntity entity) {
        this(
                entity.getIdServico(),
                entity.getCategoriaServico() != null
                        ? new CategoriaResumoDTO(entity.getCategoriaServico())
                        : null,
                entity.getNome(),
                entity.getDescricao(),
                entity.getPreco(),
                resolverImagemPrincipal(entity),
                entity.getDisponivel(),
                entity.getDestaque(),
                entity.getAtivo(),
                entity.getImagens() != null
                        ? entity.getImagens()
                        .stream()
                        .map(ServicoImagemResponseDTO::new)
                        .toList()
                        : List.of(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }

    private static String resolverImagemPrincipal(ServicoEntity entity) {
        if (entity.getImagemPrincipalUrl() != null && !entity.getImagemPrincipalUrl().isBlank()) {
            return entity.getImagemPrincipalUrl();
        }

        if (entity.getImagens() == null || entity.getImagens().isEmpty()) {
            return null;
        }

        return entity.getImagens()
                .stream()
                .filter(imagem -> Boolean.TRUE.equals(imagem.getPrincipal()))
                .findFirst()
                .map(ServicoImagemEntity::getImagemUrl)
                .orElseGet(() -> entity.getImagens()
                        .stream()
                        .findFirst()
                        .map(ServicoImagemEntity::getImagemUrl)
                        .orElse(null));
    }

    public record CategoriaResumoDTO(
            Long idCategoriaServico,
            String nome
    ) {

        public CategoriaResumoDTO(CategoriaServicoEntity entity) {
            this(
                    entity.getIdCategoriaServico(),
                    entity.getNome()
            );
        }
    }

    public record ServicoImagemResponseDTO(
            Long idServicoImagem,
            String imagemUrl,
            String legenda,
            Boolean principal,
            Integer ordem,
            LocalDateTime createdAt
    ) {

        public ServicoImagemResponseDTO(ServicoImagemEntity entity) {
            this(
                    entity.getIdServicoImagem(),
                    entity.getImagemUrl(),
                    entity.getLegenda(),
                    entity.getPrincipal(),
                    entity.getOrdem(),
                    entity.getCreatedAt()
            );
        }
    }
}