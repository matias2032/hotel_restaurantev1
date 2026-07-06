package com.dev258.hotel_restaurante_backend.cliente.repository;

import com.dev258.hotel_restaurante_backend.cliente.entity.PerfilClienteEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PerfilClienteRepository extends JpaRepository<PerfilClienteEntity, Long> {

    Optional<PerfilClienteEntity> findByNomePerfilClienteIgnoreCase(String nomePerfilCliente);

    boolean existsByNomePerfilClienteIgnoreCase(String nomePerfilCliente);

    List<PerfilClienteEntity> findAllByOrderByNomePerfilClienteAsc();
}