package com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.dto;

import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoItemEstoque;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoMovimentoEstoque;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record MovimentoEstoqueRequestDTO(

        @NotNull(message = "O tipo do item é obrigatório.")
        TipoItemEstoque tipoItem,

        Long idProduto,

        Long idIngrediente,

        @NotNull(message = "O tipo do movimento é obrigatório.")
        TipoMovimentoEstoque tipoMovimento,

        @NotBlank(message = "O motivo do movimento é obrigatório.")
        @Size(max = 180, message = "O motivo deve ter no máximo 180 caracteres.")
        String motivo,

        String observacoes,

        @NotNull(message = "A quantidade movimentada é obrigatória.")
        @DecimalMin(value = "0.001", message = "A quantidade movimentada deve ser maior que zero.")
        BigDecimal quantidadeMovimentada,

        @NotNull(message = "O usuário responsável é obrigatório.")
        Long idUsuario
) {
}