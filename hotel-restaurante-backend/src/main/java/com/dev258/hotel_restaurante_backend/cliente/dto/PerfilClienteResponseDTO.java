package com.dev258.hotel_restaurante_backend.cliente.dto;

import com.dev258.hotel_restaurante_backend.cliente.entity.PerfilClienteEntity;

public record PerfilClienteResponseDTO(
        Long idPerfilCliente,
        String nomePerfilCliente
) {

    public static PerfilClienteResponseDTO fromEntity(PerfilClienteEntity entity) {
        return new PerfilClienteResponseDTO(
                entity.getIdPerfilCliente(),
                entity.getNomePerfilCliente()
        );
    }
}