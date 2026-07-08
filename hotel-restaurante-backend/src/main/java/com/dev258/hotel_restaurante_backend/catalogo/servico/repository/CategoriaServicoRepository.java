package com.dev258.hotel_restaurante_backend.catalogo.servico.repository;

import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.CategoriaServicoEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CategoriaServicoRepository
        extends JpaRepository<CategoriaServicoEntity, Long> {

    Optional<CategoriaServicoEntity> findByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCaseAndIdCategoriaServicoNot(
            String nome,
            Long idCategoriaServico
    );

    List<CategoriaServicoEntity> findByAtivoTrueOrderByOrdemAscNomeAsc();

    List<CategoriaServicoEntity> findAllByOrderByOrdemAscNomeAsc();
}