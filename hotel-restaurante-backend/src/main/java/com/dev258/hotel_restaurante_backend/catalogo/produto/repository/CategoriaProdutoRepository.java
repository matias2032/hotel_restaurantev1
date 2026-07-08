package com.dev258.hotel_restaurante_backend.catalogo.produto.repository;

import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.CategoriaProdutoEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CategoriaProdutoRepository
        extends JpaRepository<CategoriaProdutoEntity, Long> {

    Optional<CategoriaProdutoEntity> findByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCaseAndIdCategoriaProdutoNot(
            String nome,
            Long idCategoriaProduto
    );

    List<CategoriaProdutoEntity> findByAtivoTrueOrderByOrdemAscNomeAsc();

    List<CategoriaProdutoEntity> findAllByOrderByOrdemAscNomeAsc();
}