package com.dev258.hotel_restaurante_backend.catalogo.produto.dto;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.CategoriaProdutoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoCategoriaEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoImagemEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoIngredienteEntity;
import java.util.Comparator;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

public record ProdutoResponseDTO(
        Long idProduto,

List<CategoriaResumoDTO> categoriasProduto,

        String nome,
        String descricao,

        BigDecimal preco,

        Boolean promocional,
        BigDecimal precoPromocional,

        String imagemPrincipalUrl,

        Boolean controlaEstoque,
        BigDecimal quantidadeEstoque,

        Boolean controlaEstoquePorIngredientes,

        BigDecimal quantidadeDisponivelCalculada,
        Boolean disponivelCalculado,
        String motivoIndisponibilidade,

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
                entity.getPromocional(),
                entity.getPrecoPromocional(),
                resolverImagemPrincipal(entity),
                entity.getControlaEstoque(),
                entity.getQuantidadeEstoque(),
                entity.getControlaEstoquePorIngredientes(),
                calcularQuantidadeDisponivel(entity),
                calcularDisponivel(entity),
                calcularMotivoIndisponibilidade(entity),
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

    private static Boolean calcularDisponivel(ProdutoEntity entity) {
    return calcularQuantidadeDisponivel(entity).compareTo(BigDecimal.ZERO) > 0;
}

private static BigDecimal calcularQuantidadeDisponivel(ProdutoEntity entity) {
    if (entity == null) {
        return BigDecimal.ZERO;
    }

    if (Boolean.FALSE.equals(entity.getAtivo())) {
        return BigDecimal.ZERO;
    }

    if (Boolean.FALSE.equals(entity.getDisponivel())) {
        return BigDecimal.ZERO;
    }

    BigDecimal quantidadePorEstoqueProprio = null;
    BigDecimal quantidadePorIngredientes = null;

    if (Boolean.TRUE.equals(entity.getControlaEstoque())) {
        BigDecimal estoqueProduto = entity.getQuantidadeEstoque();

        if (estoqueProduto == null || estoqueProduto.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        quantidadePorEstoqueProprio = estoqueProduto.setScale(0, RoundingMode.DOWN);
    }

    if (Boolean.TRUE.equals(entity.getControlaEstoquePorIngredientes())) {
        quantidadePorIngredientes = calcularQuantidadeDisponivelPorIngredientes(entity);
    }

    if (quantidadePorEstoqueProprio != null && quantidadePorIngredientes != null) {
        return quantidadePorEstoqueProprio.min(quantidadePorIngredientes);
    }

    if (quantidadePorEstoqueProprio != null) {
        return quantidadePorEstoqueProprio;
    }

    if (quantidadePorIngredientes != null) {
        return quantidadePorIngredientes;
    }

    return BigDecimal.valueOf(999999);
}

private static BigDecimal calcularQuantidadeDisponivelPorIngredientes(
        ProdutoEntity entity
) {
    if (entity.getIngredientes() == null || entity.getIngredientes().isEmpty()) {
        return BigDecimal.ZERO;
    }

    BigDecimal menorQuantidadePossivel = null;
    boolean encontrouIngredienteObrigatorio = false;

    for (ProdutoIngredienteEntity produtoIngrediente : entity.getIngredientes()) {
        if (!Boolean.TRUE.equals(produtoIngrediente.getObrigatorio())) {
            continue;
        }

        encontrouIngredienteObrigatorio = true;

        IngredienteEntity ingrediente = produtoIngrediente.getIngrediente();

        if (ingrediente == null) {
            return BigDecimal.ZERO;
        }

        if (Boolean.FALSE.equals(ingrediente.getAtivo())) {
            return BigDecimal.ZERO;
        }

        if (Boolean.FALSE.equals(ingrediente.getDisponivel())) {
            return BigDecimal.ZERO;
        }

        if (!Boolean.TRUE.equals(ingrediente.getControlaEstoque())) {
            continue;
        }

        BigDecimal estoqueIngrediente = ingrediente.getQuantidadeEstoque();
        BigDecimal quantidadeNecessaria = produtoIngrediente.getQuantidadePadrao();

        if (estoqueIngrediente == null || estoqueIngrediente.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        if (quantidadeNecessaria == null || quantidadeNecessaria.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        BigDecimal quantidadePossivel = estoqueIngrediente
                .divide(quantidadeNecessaria, 0, RoundingMode.DOWN);

        if (menorQuantidadePossivel == null) {
            menorQuantidadePossivel = quantidadePossivel;
        } else {
            menorQuantidadePossivel = menorQuantidadePossivel.min(quantidadePossivel);
        }
    }

    if (!encontrouIngredienteObrigatorio) {
        return BigDecimal.ZERO;
    }

    if (menorQuantidadePossivel == null) {
        return BigDecimal.valueOf(999999);
    }

    return menorQuantidadePossivel;
}

private static String calcularMotivoIndisponibilidade(ProdutoEntity entity) {
    if (entity == null) {
        return "Produto inválido.";
    }

    if (Boolean.FALSE.equals(entity.getAtivo())) {
        return "Produto inativo.";
    }

    if (Boolean.FALSE.equals(entity.getDisponivel())) {
        return "Produto marcado como indisponível.";
    }

    if (Boolean.TRUE.equals(entity.getControlaEstoque())) {
        BigDecimal estoqueProduto = entity.getQuantidadeEstoque();

        if (estoqueProduto == null || estoqueProduto.compareTo(BigDecimal.ZERO) <= 0) {
            return "Estoque do produto insuficiente.";
        }
    }

    if (Boolean.TRUE.equals(entity.getControlaEstoquePorIngredientes())) {
        String motivoIngrediente = calcularMotivoIndisponibilidadePorIngredientes(entity);

        if (motivoIngrediente != null) {
            return motivoIngrediente;
        }
    }

    return null;
}

private static String calcularMotivoIndisponibilidadePorIngredientes(
        ProdutoEntity entity
) {
    if (entity.getIngredientes() == null || entity.getIngredientes().isEmpty()) {
        return "Produto sem ingredientes obrigatórios para cálculo de estoque.";
    }

    boolean encontrouIngredienteObrigatorio = false;

    for (ProdutoIngredienteEntity produtoIngrediente : entity.getIngredientes()) {
        if (!Boolean.TRUE.equals(produtoIngrediente.getObrigatorio())) {
            continue;
        }

        encontrouIngredienteObrigatorio = true;

        IngredienteEntity ingrediente = produtoIngrediente.getIngrediente();

        if (ingrediente == null) {
            return "Ingrediente obrigatório inválido.";
        }

        String nomeIngrediente = ingrediente.getNome() != null
                ? ingrediente.getNome()
                : "ingrediente obrigatório";

        if (Boolean.FALSE.equals(ingrediente.getAtivo())) {
            return "Ingrediente obrigatório inativo: " + nomeIngrediente + ".";
        }

        if (Boolean.FALSE.equals(ingrediente.getDisponivel())) {
            return "Ingrediente obrigatório indisponível: " + nomeIngrediente + ".";
        }

        if (!Boolean.TRUE.equals(ingrediente.getControlaEstoque())) {
            continue;
        }

        BigDecimal estoqueIngrediente = ingrediente.getQuantidadeEstoque();
        BigDecimal quantidadeNecessaria = produtoIngrediente.getQuantidadePadrao();

        if (estoqueIngrediente == null || estoqueIngrediente.compareTo(BigDecimal.ZERO) <= 0) {
            return "Estoque insuficiente de " + nomeIngrediente + ".";
        }

        if (quantidadeNecessaria == null || quantidadeNecessaria.compareTo(BigDecimal.ZERO) <= 0) {
            return "Quantidade padrão inválida para " + nomeIngrediente + ".";
        }

        BigDecimal quantidadePossivel = estoqueIngrediente
                .divide(quantidadeNecessaria, 0, RoundingMode.DOWN);

        if (quantidadePossivel.compareTo(BigDecimal.ONE) < 0) {
            return "Estoque insuficiente de " + nomeIngrediente + ".";
        }
    }

    if (!encontrouIngredienteObrigatorio) {
        return "Produto sem ingredientes obrigatórios para cálculo de estoque.";
    }

    return null;
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