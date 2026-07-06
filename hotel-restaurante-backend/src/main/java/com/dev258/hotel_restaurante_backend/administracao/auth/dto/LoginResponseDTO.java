package com.dev258.hotel_restaurante_backend.administracao.auth.dto;

import com.dev258.hotel_restaurante_backend.administracao.usuario.dto.UsuarioResponseDTO;
import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;

public record LoginResponseDTO(
        String mensagem,
        Boolean primeiraSenha,
        String accessToken,
        String tokenType,
        Long expiresInMinutes,
        UsuarioResponseDTO usuario
) {

    public static LoginResponseDTO fromEntity(
            UsuarioEntity usuario,
            String accessToken,
            Long expiresInMinutes
    ) {
        return new LoginResponseDTO(
                usuario.getPrimeiraSenha() != null && usuario.getPrimeiraSenha()
                        ? "Primeiro acesso. É necessário definir uma nova senha."
                        : "Login realizado com sucesso.",
                usuario.getPrimeiraSenha(),
                accessToken,
                "Bearer",
                expiresInMinutes,
                UsuarioResponseDTO.fromEntity(usuario)
        );
    }
}