package com.dev258.hotel_restaurante_backend.catalogo.servico.dto;

import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.CategoriaServicoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoImagemEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoCategoriaEntity;
import java.util.Comparator;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record ServicoResponseDTO(
        Long idServico,

List<CategoriaResumoDTO> categoriasServico,

        String nome,
        String descricao,

        BigDecimal preco,

        String imagemPrincipalUrl,

        Boolean destaque,
        Boolean disponivelCalculado,
        String motivoIndisponibilidade,
        Boolean ativo,

        List<ServicoImagemResponseDTO> imagens,

        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public ServicoResponseDTO(ServicoEntity entity) {
        this(
                entity.getIdServico(),
                resolverCategorias(entity),
                entity.getNome(),
                entity.getDescricao(),
                entity.getPreco(),
                resolverImagemPrincipal(entity),
                entity.getDestaque(),
                calcularDisponivel(entity),
                calcularMotivoIndisponibilidade(entity),
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

    private static Boolean calcularDisponivel(
        ServicoEntity entity
) {
    return entity != null
            && Boolean.TRUE.equals(entity.getAtivo());
}

private static String calcularMotivoIndisponibilidade(
        ServicoEntity entity
) {
    if (entity == null) {
        return "Serviço inválido.";
    }

    if (Boolean.FALSE.equals(entity.getAtivo())) {
        return "Serviço inativo.";
    }

    return null;
}

    private static List<CategoriaResumoDTO> resolverCategorias(
        ServicoEntity entity
) {
    if (entity.getCategorias() == null || entity.getCategorias().isEmpty()) {
        return List.of();
    }

    return entity.getCategorias()
            .stream()
            .sorted(
                    Comparator
                            .comparing(
                                    ServicoCategoriaEntity::getPrincipal,
                                    Comparator.nullsLast(Comparator.reverseOrder())
                            )
                            .thenComparing(
                                    ServicoCategoriaEntity::getOrdem,
                                    Comparator.nullsLast(Integer::compareTo)
                            )
                            .thenComparing(categoria -> categoria
                                    .getCategoriaServico()
                                    .getNome()
                            )
            )
            .map(CategoriaResumoDTO::new)
            .toList();
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
        String nome,
        Boolean principal,
        Integer ordem
) {

    public CategoriaResumoDTO(ServicoCategoriaEntity entity) {
        this(
                entity.getCategoriaServico().getIdCategoriaServico(),
                entity.getCategoriaServico().getNome(),
                entity.getPrincipal(),
                entity.getOrdem()
        );
    }

    public CategoriaResumoDTO(CategoriaServicoEntity entity) {
        this(
                entity.getIdCategoriaServico(),
                entity.getNome(),
                false,
                0
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