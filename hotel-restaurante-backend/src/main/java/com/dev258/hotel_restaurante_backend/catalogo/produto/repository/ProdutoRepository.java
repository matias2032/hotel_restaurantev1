package com.dev258.hotel_restaurante_backend.catalogo.produto.repository;

import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProdutoRepository
        extends JpaRepository<ProdutoEntity, Long> {

    boolean existsByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCaseAndIdProdutoNot(
            String nome,
            Long idProduto
    );

    List<ProdutoEntity> findByAtivoTrueOrderByNomeAsc();

    List<ProdutoEntity> findAllByOrderByNomeAsc();

    List<ProdutoEntity> findByDisponivelTrueAndAtivoTrueOrderByNomeAsc();

    List<ProdutoEntity> findByDestaqueTrueAndAtivoTrueOrderByNomeAsc();

    List<ProdutoEntity> findByCategoriaProduto_IdCategoriaProdutoAndAtivoTrueOrderByNomeAsc(
            Long idCategoriaProduto
    );

    List<ProdutoEntity> findByCategoriaProduto_IdCategoriaProdutoOrderByNomeAsc(
            Long idCategoriaProduto
    );

    List<ProdutoEntity> findByCategoriaProduto_IdCategoriaProdutoAndDisponivelTrueAndAtivoTrueOrderByNomeAsc(
            Long idCategoriaProduto
    );
}