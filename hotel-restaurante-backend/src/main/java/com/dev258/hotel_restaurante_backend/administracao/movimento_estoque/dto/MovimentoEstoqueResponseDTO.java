package com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.dto;

import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.OrigemMovimentoEstoque;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoItemEstoque;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoMovimentoEstoque;
import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoEntity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record MovimentoEstoqueResponseDTO(
        Long idMovimentoEstoque,

        TipoItemEstoque tipoItem,

        Long idProduto,
        String nomeProduto,

        Long idIngrediente,
        String nomeIngrediente,

        TipoMovimentoEstoque tipoMovimento,

        String motivo,
        String observacoes,

        BigDecimal quantidadeMovimentada,
        BigDecimal quantidadeAnterior,
        BigDecimal quantidadePosterior,

        Long idUsuario,
        String nomeUsuario,
        String apelidoUsuario,
        String nomeCompletoUsuario,


        OrigemMovimentoEstoque origem,

        LocalDateTime movimentadoEm,
        LocalDateTime createdAt
) {

    public MovimentoEstoqueResponseDTO(MovimentoEstoqueEntity entity) {
        this(
                entity.getIdMovimentoEstoque(),

                entity.getTipoItem(),

                resolverIdProduto(entity),
                resolverNomeProduto(entity),

                resolverIdIngrediente(entity),
                resolverNomeIngrediente(entity),

                entity.getTipoMovimento(),

                entity.getMotivo(),
                entity.getObservacoes(),

                entity.getQuantidadeMovimentada(),
                entity.getQuantidadeAnterior(),
                entity.getQuantidadePosterior(),

                resolverIdUsuario(entity),
                resolverNomeUsuario(entity),
                resolverApelidoUsuario(entity),
                resolverNomeCompletoUsuario(entity),


                entity.getOrigem(),

                entity.getMovimentadoEm(),
                entity.getCreatedAt()
        );
    }

    private static Long resolverIdProduto(MovimentoEstoqueEntity entity) {
        ProdutoEntity produto = entity.getProduto();
        return produto != null ? produto.getIdProduto() : null;
    }

    private static String resolverNomeProduto(MovimentoEstoqueEntity entity) {
        ProdutoEntity produto = entity.getProduto();
        return produto != null ? produto.getNome() : null;
    }

    private static Long resolverIdIngrediente(MovimentoEstoqueEntity entity) {
        IngredienteEntity ingrediente = entity.getIngrediente();
        return ingrediente != null ? ingrediente.getIdIngrediente() : null;
    }

    private static String resolverNomeIngrediente(MovimentoEstoqueEntity entity) {
        IngredienteEntity ingrediente = entity.getIngrediente();
        return ingrediente != null ? ingrediente.getNome() : null;
    }

    private static Long resolverIdUsuario(MovimentoEstoqueEntity entity) {
        UsuarioEntity usuario = entity.getUsuario();
        return usuario != null ? usuario.getIdUsuario() : null;
    }

    private static String resolverNomeUsuario(MovimentoEstoqueEntity entity) {
        UsuarioEntity usuario = entity.getUsuario();
        return usuario != null ? usuario.getNome() : null;
    }

    private static String resolverApelidoUsuario(MovimentoEstoqueEntity entity) {
        UsuarioEntity usuario = entity.getUsuario();
        return usuario != null ? usuario.getApelido() : null;
    }

    private static String resolverNomeCompletoUsuario(MovimentoEstoqueEntity entity) {
        UsuarioEntity usuario = entity.getUsuario();

        if (usuario == null) {
            return null;
        }

        String nome = usuario.getNome() != null ? usuario.getNome().trim() : "";
        String apelido = usuario.getApelido() != null ? usuario.getApelido().trim() : "";

        String nomeCompleto = (nome + " " + apelido).trim();

        return nomeCompleto.isEmpty() ? null : nomeCompleto;
    }

    

    
}