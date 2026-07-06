package com.dev258.hotel_restaurante_backend.cliente.repository;

import com.dev258.hotel_restaurante_backend.cliente.entity.ClienteEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ClienteRepository extends JpaRepository<ClienteEntity, Long> {

    Optional<ClienteEntity> findByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCase(String email);

    List<ClienteEntity> findByAtivoOrderByNomeAsc(Boolean ativo);

    List<ClienteEntity> findAllByOrderByNomeAsc();

    Optional<ClienteEntity> findFirstByEmailIgnoreCaseOrTelefoneIgnoreCase(
            String email,
            String telefone
    );

    Optional<ClienteEntity> findFirstByEmailIgnoreCaseOrTelefoneIgnoreCaseOrApelidoIgnoreCase(
            String email,
            String telefone,
            String apelido
    );
}