package com.dev258.hotel_restaurante_backend.catalogo.servico.repository;

import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoCategoriaEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoCategoriaId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ServicoCategoriaRepository
        extends JpaRepository<ServicoCategoriaEntity, ServicoCategoriaId> {

    List<ServicoCategoriaEntity> findByServico_IdServicoOrderByPrincipalDescOrdemAsc(
            Long idServico
    );

    List<ServicoCategoriaEntity> findByCategoriaServico_IdCategoriaServicoOrderByServico_NomeAsc(
            Long idCategoriaServico
    );

    boolean existsByCategoriaServico_IdCategoriaServicoAndServico_AtivoTrue(
            Long idCategoriaServico
    );

    boolean existsByServico_IdServicoAndCategoriaServico_IdCategoriaServico(
            Long idServico,
            Long idCategoriaServico
    );

    void deleteByServico_IdServico(Long idServico);
}