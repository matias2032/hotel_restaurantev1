package com.dev258.hotel_restaurante_backend.catalogo.servico.repository;

import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoImagemEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ServicoImagemRepository
        extends JpaRepository<ServicoImagemEntity, Long> {

    List<ServicoImagemEntity> findByServico_IdServicoOrderByPrincipalDescOrdemAscIdServicoImagemAsc(
            Long idServico
    );

    Optional<ServicoImagemEntity> findFirstByServico_IdServicoAndPrincipalTrue(
            Long idServico
    );

    void deleteByServico_IdServico(Long idServico);

    boolean existsByServico_IdServicoAndImagemUrl(
            Long idServico,
            String imagemUrl
    );
}