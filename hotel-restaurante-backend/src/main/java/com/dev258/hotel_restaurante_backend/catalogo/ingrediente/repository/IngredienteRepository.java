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


    List<IngredienteEntity> findDistinctByCategorias_CategoriaIngrediente_IdCategoriaIngredienteOrderByNomeAsc(
            Long idCategoriaIngrediente
    );

    List<IngredienteEntity> findDistinctByCategorias_CategoriaIngrediente_IdCategoriaIngredienteAndAtivoTrueOrderByNomeAsc(
            Long idCategoriaIngrediente
    );
}