package com.dev258.hotel_restaurante_backend.catalogo.produto.repository;

import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoImagemEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProdutoImagemRepository
        extends JpaRepository<ProdutoImagemEntity, Long> {

    List<ProdutoImagemEntity> findByProduto_IdProdutoOrderByPrincipalDescOrdemAscIdProdutoImagemAsc(
            Long idProduto
    );

    Optional<ProdutoImagemEntity> findFirstByProduto_IdProdutoAndPrincipalTrue(
            Long idProduto
    );

    void deleteByProduto_IdProduto(Long idProduto);

    boolean existsByProduto_IdProdutoAndImagemUrl(
            Long idProduto,
            String imagemUrl
    );
}