package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto;

import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoMovimentoEstoque;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;


import java.math.BigDecimal;
import java.util.List;

public record IngredienteRequestDTO(

        /*
         * Agora o ingrediente pode pertencer a várias categorias.
         *
         * Regra recomendada no service:
         * - idCategoriasIngrediente == null -> mantém categorias atuais na edição.
         * - idCategoriasIngrediente == []   -> remove todas as categorias.
         * - lista com IDs                   -> substitui pelas categorias enviadas.
         */
        List<Long> idCategoriasIngrediente,

        @NotBlank(message = "O nome do ingrediente é obrigatório.")
        @Size(max = 120, message = "O nome do ingrediente deve ter no máximo 120 caracteres.")
        String nome,

        String descricao,

        @DecimalMin(value = "0.00", message = "O preço adicional não pode ser negativo.")
        BigDecimal precoAdicional,

        Boolean controlaEstoque,

        @DecimalMin(value = "0.000", message = "A quantidade em estoque não pode ser negativa.")
        BigDecimal quantidadeEstoque,



        Boolean ativo,
        TipoMovimentoEstoque tipoMovimentoEstoque,

        String motivoMovimentoEstoque,

        String observacoesMovimentoEstoque,

        Long idUsuarioMovimentoEstoque,

        @Valid
        List<IngredienteImagemRequestDTO> imagens
) {

    public record IngredienteImagemRequestDTO(

            String imagemUrl,

            @Size(max = 160, message = "A legenda deve ter no máximo 160 caracteres.")
            String legenda,

            Boolean principal,

            @Min(value = 0, message = "A ordem da imagem não pode ser negativa.")
            Integer ordem
    ) {
    }
}