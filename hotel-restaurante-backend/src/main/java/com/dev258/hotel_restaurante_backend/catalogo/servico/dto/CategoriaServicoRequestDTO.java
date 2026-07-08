package com.dev258.hotel_restaurante_backend.catalogo.servico.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CategoriaServicoRequestDTO(

        @NotBlank(message = "O nome da categoria é obrigatório.")
        @Size(max = 120, message = "O nome da categoria deve ter no máximo 120 caracteres.")
        String nome,

        String descricao,

        @Min(value = 0, message = "A ordem não pode ser negativa.")
        Integer ordem,

        Boolean ativo
) {
}