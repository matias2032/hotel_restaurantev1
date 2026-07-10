package com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.repository;

import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoItemEstoque;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoMovimentoEstoque;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface MovimentoEstoqueRepository
        extends JpaRepository<MovimentoEstoqueEntity, Long> {

    // ─────────────────────────────────────────────────────────────
    // LISTAGEM GERAL
    // ─────────────────────────────────────────────────────────────

    List<MovimentoEstoqueEntity> findAllByOrderByMovimentadoEmDescIdMovimentoEstoqueDesc();

    List<MovimentoEstoqueEntity> findByMovimentadoEmBetweenOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            LocalDateTime inicio,
            LocalDateTime fim
    );

    // ─────────────────────────────────────────────────────────────
    // FILTROS POR TIPO DE ITEM
    // ─────────────────────────────────────────────────────────────

    List<MovimentoEstoqueEntity> findByTipoItemOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            TipoItemEstoque tipoItem
    );

    List<MovimentoEstoqueEntity> findByTipoItemAndMovimentadoEmBetweenOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            TipoItemEstoque tipoItem,
            LocalDateTime inicio,
            LocalDateTime fim
    );

    // ─────────────────────────────────────────────────────────────
    // FILTROS POR PRODUTO
    // ─────────────────────────────────────────────────────────────

    List<MovimentoEstoqueEntity> findByProduto_IdProdutoOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            Long idProduto
    );

    List<MovimentoEstoqueEntity> findByProduto_IdProdutoAndMovimentadoEmBetweenOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            Long idProduto,
            LocalDateTime inicio,
            LocalDateTime fim
    );

    // ─────────────────────────────────────────────────────────────
    // FILTROS POR INGREDIENTE
    // ─────────────────────────────────────────────────────────────

    List<MovimentoEstoqueEntity> findByIngrediente_IdIngredienteOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            Long idIngrediente
    );

    List<MovimentoEstoqueEntity> findByIngrediente_IdIngredienteAndMovimentadoEmBetweenOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            Long idIngrediente,
            LocalDateTime inicio,
            LocalDateTime fim
    );

    // ─────────────────────────────────────────────────────────────
    // FILTROS POR USUÁRIO / OPERADOR
    // ─────────────────────────────────────────────────────────────

    List<MovimentoEstoqueEntity> findByUsuario_IdUsuarioOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            Long idUsuario
    );

    List<MovimentoEstoqueEntity> findByUsuario_IdUsuarioAndMovimentadoEmBetweenOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            Long idUsuario,
            LocalDateTime inicio,
            LocalDateTime fim
    );

    // ─────────────────────────────────────────────────────────────
    // FILTROS POR TIPO DE MOVIMENTO
    // ─────────────────────────────────────────────────────────────

    List<MovimentoEstoqueEntity> findByTipoMovimentoOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            TipoMovimentoEstoque tipoMovimento
    );

    List<MovimentoEstoqueEntity> findByTipoMovimentoAndMovimentadoEmBetweenOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
            TipoMovimentoEstoque tipoMovimento,
            LocalDateTime inicio,
            LocalDateTime fim
    );
}