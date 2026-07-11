package com.dev258.hotel_restaurante_backend.catalogo.servico.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.List;

public record ServicoRequestDTO(

List<Long> idCategoriasServico,

        @NotBlank(message = "O nome do serviço é obrigatório.")
        @Size(max = 160, message = "O nome do serviço deve ter no máximo 160 caracteres.")
        String nome,

        String descricao,

        @DecimalMin(value = "0.00", message = "O preço do serviço não pode ser negativo.")
        BigDecimal preco,

        String imagemPrincipalUrl,


        Boolean destaque,

        Boolean ativo,

        @Valid
        List<ServicoImagemRequestDTO> imagens
) {

    public record ServicoImagemRequestDTO(

            String imagemUrl,

            @Size(max = 160, message = "A legenda deve ter no máximo 160 caracteres.")
            String legenda,

            Boolean principal,

            @Min(value = 0, message = "A ordem da imagem não pode ser negativa.")
            Integer ordem
    ) {
    }
}