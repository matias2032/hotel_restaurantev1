package com.dev258.hotel_restaurante_backend.catalogo.produto.dto;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.CategoriaProdutoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoCategoriaEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoImagemEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoIngredienteEntity;
import java.util.Comparator;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record ProdutoResponseDTO(
        Long idProduto,

List<CategoriaResumoDTO> categoriasProduto,

        String nome,
        String descricao,

        BigDecimal preco,

        String imagemPrincipalUrl,

        Boolean controlaEstoque,
        BigDecimal quantidadeEstoque,

        Integer tempoPreparoMinutos,

        Boolean disponivel,
        Boolean destaque,
        Boolean ativo,

        List<ProdutoImagemResponseDTO> imagens,

        List<ProdutoIngredienteResponseDTO> ingredientes,

        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public ProdutoResponseDTO(ProdutoEntity entity) {
        this(
                entity.getIdProduto(),
             resolverCategorias(entity),
                entity.getNome(),
                entity.getDescricao(),
                entity.getPreco(),
                resolverImagemPrincipal(entity),
                entity.getControlaEstoque(),
                entity.getQuantidadeEstoque(),
                entity.getTempoPreparoMinutos(),
                entity.getDisponivel(),
                entity.getDestaque(),
                entity.getAtivo(),
                entity.getImagens() != null
                        ? entity.getImagens()
                        .stream()
                        .map(ProdutoImagemResponseDTO::new)
                        .toList()
                        : List.of(),
                entity.getIngredientes() != null
                        ? entity.getIngredientes()
                        .stream()
                        .map(ProdutoIngredienteResponseDTO::new)
                        .toList()
                        : List.of(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }

    private static List<CategoriaResumoDTO> resolverCategorias(
        ProdutoEntity entity) {
    if (entity.getCategorias() == null || entity.getCategorias().isEmpty()) {
        return List.of();
    }
    return entity.getCategorias()
            .stream()
            .sorted(
                    Comparator
                            .comparing(
                                    ProdutoCategoriaEntity::getPrincipal,
                                    Comparator.nullsLast(Comparator.reverseOrder())
                            )
                            .thenComparing(
                                    ProdutoCategoriaEntity::getOrdem,
                                    Comparator.nullsLast(Integer::compareTo)
                            )
                            .thenComparing(categoria -> categoria
                                    .getCategoriaProduto()
                                    .getNome()
                            )
            )
            .map(CategoriaResumoDTO::new)
            .toList();
}


    
    

    private static String resolverImagemPrincipal(ProdutoEntity entity) {
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
                .map(ProdutoImagemEntity::getImagemUrl)
                .orElseGet(() -> entity.getImagens()
                        .stream()
                        .findFirst()
                        .map(ProdutoImagemEntity::getImagemUrl)
                        .orElse(null));
    }

public record CategoriaResumoDTO(
        Long idCategoriaProduto,
        String nome,
        Boolean principal,
        Integer ordem
) {

    public CategoriaResumoDTO(ProdutoCategoriaEntity entity) {
        this(
                entity.getCategoriaProduto().getIdCategoriaProduto(),
                entity.getCategoriaProduto().getNome(),
                entity.getPrincipal(),
                entity.getOrdem()
        );
    }

    public CategoriaResumoDTO(CategoriaProdutoEntity entity) {
        this(
                entity.getIdCategoriaProduto(),
                entity.getNome(),
                false,
                0
        );
    }
}

    public record ProdutoImagemResponseDTO(
            Long idProdutoImagem,
            String imagemUrl,
            String legenda,
            Boolean principal,
            Integer ordem,
            LocalDateTime createdAt
    ) {

        public ProdutoImagemResponseDTO(ProdutoImagemEntity entity) {
            this(
                    entity.getIdProdutoImagem(),
                    entity.getImagemUrl(),
                    entity.getLegenda(),
                    entity.getPrincipal(),
                    entity.getOrdem(),
                    entity.getCreatedAt()
            );
        }
    }

    public record ProdutoIngredienteResponseDTO(
            Long idIngrediente,
            String nomeIngrediente,
            String descricaoIngrediente,
            BigDecimal precoAdicional,
            Boolean ingredienteDisponivel,
            Boolean ingredienteAtivo,
            Boolean obrigatorio,
            Boolean removivel,
            Boolean permiteExtra,
            BigDecimal quantidadePadrao
    ) {

        public ProdutoIngredienteResponseDTO(ProdutoIngredienteEntity entity) {
            this(
                    resolverIdIngrediente(entity),
                    resolverNomeIngrediente(entity),
                    resolverDescricaoIngrediente(entity),
                    resolverPrecoAdicional(entity),
                    resolverIngredienteDisponivel(entity),
                    resolverIngredienteAtivo(entity),
                    entity.getObrigatorio(),
                    entity.getRemovivel(),
                    entity.getPermiteExtra(),
                    entity.getQuantidadePadrao()
            );
        }

        private static Long resolverIdIngrediente(ProdutoIngredienteEntity entity) {
            IngredienteEntity ingrediente = entity.getIngrediente();
            return ingrediente != null ? ingrediente.getIdIngrediente() : null;
        }

        private static String resolverNomeIngrediente(ProdutoIngredienteEntity entity) {
            IngredienteEntity ingrediente = entity.getIngrediente();
            return ingrediente != null ? ingrediente.getNome() : null;
        }

        private static String resolverDescricaoIngrediente(ProdutoIngredienteEntity entity) {
            IngredienteEntity ingrediente = entity.getIngrediente();
            return ingrediente != null ? ingrediente.getDescricao() : null;
        }

        private static BigDecimal resolverPrecoAdicional(ProdutoIngredienteEntity entity) {
            IngredienteEntity ingrediente = entity.getIngrediente();
            return ingrediente != null ? ingrediente.getPrecoAdicional() : null;
        }

        private static Boolean resolverIngredienteDisponivel(ProdutoIngredienteEntity entity) {
            IngredienteEntity ingrediente = entity.getIngrediente();
            return ingrediente != null ? ingrediente.getDisponivel() : null;
        }

        private static Boolean resolverIngredienteAtivo(ProdutoIngredienteEntity entity) {
            IngredienteEntity ingrediente = entity.getIngrediente();
            return ingrediente != null ? ingrediente.getAtivo() : null;
        }
    }
}