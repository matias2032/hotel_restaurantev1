package com.dev258.hotel_restaurante_backend.catalogo.produto.repository;

import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoIngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoIngredienteId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProdutoIngredienteRepository
        extends JpaRepository<ProdutoIngredienteEntity, ProdutoIngredienteId> {

    List<ProdutoIngredienteEntity> findByProduto_IdProdutoOrderByIngrediente_NomeAsc(
            Long idProduto
    );

    List<ProdutoIngredienteEntity> findByIngrediente_IdIngredienteOrderByProduto_NomeAsc(
            Long idIngrediente
    );

    boolean existsByProduto_IdProdutoAndIngrediente_IdIngrediente(
            Long idProduto,
            Long idIngrediente
    );

    void deleteByProduto_IdProduto(Long idProduto);

    void deleteByProduto_IdProdutoAndIngrediente_IdIngrediente(
            Long idProduto,
            Long idIngrediente
    );
}