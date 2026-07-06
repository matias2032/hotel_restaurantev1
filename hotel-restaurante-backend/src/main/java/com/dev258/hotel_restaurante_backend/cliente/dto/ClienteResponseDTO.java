package com.dev258.hotel_restaurante_backend.cliente.dto;

import com.dev258.hotel_restaurante_backend.cliente.entity.ClienteEntity;

import java.time.LocalDateTime;

public record ClienteResponseDTO(
        Long idCliente,
        PerfilClienteResponseDTO perfilCliente,
        String nome,
        String apelido,
        String email,
        String telefone,
        Boolean primeiraSenha,
        String nuit,
        Boolean ativo,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public static ClienteResponseDTO fromEntity(ClienteEntity entity) {
        return new ClienteResponseDTO(
                entity.getIdCliente(),
                PerfilClienteResponseDTO.fromEntity(entity.getPerfilCliente()),
                entity.getNome(),
                entity.getApelido(),
                entity.getEmail(),
                entity.getTelefone(),
                 entity.getPrimeiraSenha(),
                entity.getNuit(),
                entity.getAtivo(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}