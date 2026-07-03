package com.dev258.hotel_restaurante_backend.administracao.usuario.dto;

import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;

public record UsuarioResumoDTO(
        Long idUsuario,
        String nomeCompleto,
        String email,
        String nomePerfil,
        Boolean primeiraSenha,
        Boolean status
) {

    public static UsuarioResumoDTO fromEntity(UsuarioEntity usuario) {
        if (usuario == null) {
            return null;
        }

        String nome = usuario.getNome() == null ? "" : usuario.getNome().trim();
        String apelido = usuario.getApelido() == null ? "" : usuario.getApelido().trim();
        String nomeCompleto = (nome + " " + apelido).trim();

        return new UsuarioResumoDTO(
                usuario.getIdUsuario(),
                nomeCompleto,
                usuario.getEmail(),
                usuario.getPerfil() != null ? usuario.getPerfil().getNomePerfil() : null,
                usuario.getPrimeiraSenha(),
                usuario.getStatus()
        );
    }
}