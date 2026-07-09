package com.dev258.hotel_restaurante_backend.catalogo.produto.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.List;

public record ProdutoRequestDTO(

        List<Long> idCategoriasProduto,

        @NotBlank(message = "O nome do produto é obrigatório.")
        @Size(max = 160, message = "O nome do produto deve ter no máximo 160 caracteres.")
        String nome,

        String descricao,

        @DecimalMin(value = "0.00", message = "O preço do produto não pode ser negativo.")
        BigDecimal preco,

        String imagemPrincipalUrl,

        Boolean controlaEstoque,

        @DecimalMin(value = "0.000", message = "A quantidade em estoque não pode ser negativa.")
        BigDecimal quantidadeEstoque,

        @Min(value = 0, message = "O tempo de preparo não pode ser negativo.")
        Integer tempoPreparoMinutos,

        Boolean disponivel,

        Boolean destaque,

        Boolean ativo,

        @Valid
        List<ProdutoImagemRequestDTO> imagens,

        @Valid
        List<ProdutoIngredienteRequestDTO> ingredientes
) {

    public record ProdutoImagemRequestDTO(

            String imagemUrl,

            @Size(max = 160, message = "A legenda deve ter no máximo 160 caracteres.")
            String legenda,

            Boolean principal,

            @Min(value = 0, message = "A ordem da imagem não pode ser negativa.")
            Integer ordem
    ) {
    }

    public record ProdutoIngredienteRequestDTO(

            Long idIngrediente,

            Boolean obrigatorio,

            Boolean removivel,

            Boolean permiteExtra,

            @DecimalMin(value = "0.001", message = "A quantidade padrão deve ser maior que zero.")
            BigDecimal quantidadePadrao
    ) {
    }
}