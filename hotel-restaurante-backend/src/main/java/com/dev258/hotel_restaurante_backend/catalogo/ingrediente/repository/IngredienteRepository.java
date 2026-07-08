package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface IngredienteRepository
        extends JpaRepository<IngredienteEntity, Long> {

    boolean existsByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCaseAndIdIngredienteNot(
            String nome,
            Long idIngrediente
    );

    List<IngredienteEntity> findByAtivoTrueOrderByNomeAsc();

    List<IngredienteEntity> findAllByOrderByNomeAsc();

    List<IngredienteEntity> findByDisponivelTrueAndAtivoTrueOrderByNomeAsc();

    List<IngredienteEntity> findByCategoriaIngrediente_IdCategoriaIngredienteAndAtivoTrueOrderByNomeAsc(
            Long idCategoriaIngrediente
    );

    List<IngredienteEntity> findByCategoriaIngrediente_IdCategoriaIngredienteOrderByNomeAsc(
            Long idCategoriaIngrediente
    );
}