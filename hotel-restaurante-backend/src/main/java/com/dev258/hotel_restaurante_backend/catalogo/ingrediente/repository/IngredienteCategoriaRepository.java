package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteCategoriaEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteCategoriaId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface IngredienteCategoriaRepository
        extends JpaRepository<IngredienteCategoriaEntity, IngredienteCategoriaId> {

    List<IngredienteCategoriaEntity> findByIngrediente_IdIngredienteOrderByPrincipalDescOrdemAsc(
            Long idIngrediente
    );

    List<IngredienteCategoriaEntity> findByCategoriaIngrediente_IdCategoriaIngredienteOrderByIngrediente_NomeAsc(
            Long idCategoriaIngrediente
    );

    boolean existsByCategoriaIngrediente_IdCategoriaIngredienteAndIngrediente_AtivoTrue(
            Long idCategoriaIngrediente
    );

    boolean existsByIngrediente_IdIngredienteAndCategoriaIngrediente_IdCategoriaIngrediente(
            Long idIngrediente,
            Long idCategoriaIngrediente
    );

    void deleteByIngrediente_IdIngrediente(Long idIngrediente);
}