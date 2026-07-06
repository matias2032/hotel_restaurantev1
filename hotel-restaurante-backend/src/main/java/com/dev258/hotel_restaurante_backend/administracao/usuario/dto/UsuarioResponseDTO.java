package com.dev258.hotel_restaurante_backend.administracao.usuario.dto;

import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;

import java.time.LocalDateTime;

public record UsuarioResponseDTO(
        Long idUsuario,
        Long idEstabelecimento,
        String nome,
        String apelido,
        String nomeCompleto,
        String email,
        String telefone,
        Boolean primeiraSenha,
              Boolean ativo,
        LocalDateTime ultimoLoginAt,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        PerfilResponseDTO perfil
) {

    public static UsuarioResponseDTO fromEntity(UsuarioEntity usuario) {
        if (usuario == null) {
            return null;
        }

        String nomeCompleto = montarNomeCompleto(usuario.getNome(), usuario.getApelido());

        return new UsuarioResponseDTO(
                usuario.getIdUsuario(),
                usuario.getIdEstabelecimento(),
                usuario.getNome(),
                usuario.getApelido(),
                nomeCompleto,
                usuario.getEmail(),
                usuario.getTelefone(),
                usuario.getPrimeiraSenha(),
                usuario.getAtivo(),
                usuario.getUltimoLoginAt(),
                usuario.getCreatedAt(),
                usuario.getUpdatedAt(),
                PerfilResponseDTO.fromEntity(usuario.getPerfil())
        );
    }

    private static String montarNomeCompleto(String nome, String apelido) {
        String n = nome == null ? "" : nome.trim();
        String a = apelido == null ? "" : apelido.trim();

        return (n + " " + a).trim();
    }
}