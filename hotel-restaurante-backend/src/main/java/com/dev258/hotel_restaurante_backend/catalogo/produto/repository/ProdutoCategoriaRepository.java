package com.dev258.hotel_restaurante_backend.catalogo.produto.repository;

import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoCategoriaEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoCategoriaId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProdutoCategoriaRepository
        extends JpaRepository<ProdutoCategoriaEntity, ProdutoCategoriaId> {

    List<ProdutoCategoriaEntity> findByProduto_IdProdutoOrderByPrincipalDescOrdemAsc(
            Long idProduto
    );

    List<ProdutoCategoriaEntity> findByCategoriaProduto_IdCategoriaProdutoOrderByProduto_NomeAsc(
            Long idCategoriaProduto
    );

    boolean existsByCategoriaProduto_IdCategoriaProdutoAndProduto_AtivoTrue(
            Long idCategoriaProduto
    );

    boolean existsByProduto_IdProdutoAndCategoriaProduto_IdCategoriaProduto(
            Long idProduto,
            Long idCategoriaProduto
    );

    void deleteByProduto_IdProduto(Long idProduto);
}