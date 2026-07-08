package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.CategoriaIngredienteEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CategoriaIngredienteRepository
        extends JpaRepository<CategoriaIngredienteEntity, Long> {

    Optional<CategoriaIngredienteEntity> findByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCaseAndIdCategoriaIngredienteNot(
            String nome,
            Long idCategoriaIngrediente
    );

    List<CategoriaIngredienteEntity> findByAtivoTrueOrderByOrdemAscNomeAsc();

    List<CategoriaIngredienteEntity> findAllByOrderByOrdemAscNomeAsc();
}