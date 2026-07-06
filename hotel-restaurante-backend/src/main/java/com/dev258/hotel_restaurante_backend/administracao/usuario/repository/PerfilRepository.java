package com.dev258.hotel_restaurante_backend.administracao.usuario.repository;

import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.PerfilEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PerfilRepository extends JpaRepository<PerfilEntity, Long> {
    Optional<PerfilEntity> findByNomePerfilIgnoreCase(String nomePerfil);
    boolean existsByNomePerfilIgnoreCase(String nomePerfil);
List<PerfilEntity> findByAtivoOrderByNomePerfilAsc(Boolean ativo);

List<PerfilEntity> findAllByOrderByNomePerfilAsc();

}