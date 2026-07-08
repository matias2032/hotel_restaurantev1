package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteImagemEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface IngredienteImagemRepository
        extends JpaRepository<IngredienteImagemEntity, Long> {

    List<IngredienteImagemEntity> findByIngrediente_IdIngredienteOrderByPrincipalDescOrdemAscIdIngredienteImagemAsc(
            Long idIngrediente
    );

    Optional<IngredienteImagemEntity> findFirstByIngrediente_IdIngredienteAndPrincipalTrue(
            Long idIngrediente
    );

    void deleteByIngrediente_IdIngrediente(Long idIngrediente);

    boolean existsByIngrediente_IdIngredienteAndImagemUrl(
            Long idIngrediente,
            String imagemUrl
    );
}