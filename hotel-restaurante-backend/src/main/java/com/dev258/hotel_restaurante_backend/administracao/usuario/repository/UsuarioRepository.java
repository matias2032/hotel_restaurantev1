package com.dev258.hotel_restaurante_backend.administracao.usuario.repository;

import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<UsuarioEntity, Long> {
    Optional<UsuarioEntity> findByEmailIgnoreCase(String email);
    boolean existsByEmailIgnoreCase(String email);
    List<UsuarioEntity> findByStatusOrderByNomeAsc(Boolean status);
    List<UsuarioEntity> findAllByOrderByNomeAsc();
}