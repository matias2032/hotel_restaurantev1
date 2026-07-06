package com.dev258.hotel_restaurante_backend.cliente.dto;

import com.dev258.hotel_restaurante_backend.cliente.entity.ClienteEntity;

public record ClienteResumoDTO(
        Long idCliente,
        String nome,
        String email,
          Boolean primeiraSenha,
        Boolean ativo
) {

    public static ClienteResumoDTO fromEntity(ClienteEntity entity) {
        return new ClienteResumoDTO(
                entity.getIdCliente(),
                entity.getNome(),
                entity.getEmail(),
                entity.getPrimeiraSenha(),
                entity.getAtivo()
        );
    }
}