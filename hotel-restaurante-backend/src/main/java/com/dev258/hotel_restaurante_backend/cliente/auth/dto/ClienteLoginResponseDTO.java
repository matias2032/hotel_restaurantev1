package com.dev258.hotel_restaurante_backend.cliente.auth.dto;

import com.dev258.hotel_restaurante_backend.cliente.dto.ClienteResponseDTO;
import com.dev258.hotel_restaurante_backend.cliente.entity.ClienteEntity;

public record ClienteLoginResponseDTO(
        String mensagem,
        Boolean primeiraSenha,
        String accessToken,
        String tokenType,
        Long expiresInMinutes,
        ClienteResponseDTO cliente
) {

    public static ClienteLoginResponseDTO fromEntity(
            ClienteEntity cliente,
            String accessToken,
            Long expiresInMinutes
    ) {
        return new ClienteLoginResponseDTO(
                cliente.getPrimeiraSenha() != null && cliente.getPrimeiraSenha()
                        ? "Primeiro acesso. É necessário definir uma nova senha."
                        : "Login realizado com sucesso.",
                cliente.getPrimeiraSenha(),
                accessToken,
                "Bearer",
                expiresInMinutes,
                ClienteResponseDTO.fromEntity(cliente)
        );
    }
}