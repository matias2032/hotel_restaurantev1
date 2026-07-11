package com.dev258.hotel_restaurante_backend.catalogo.servico.repository;

import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ServicoRepository
        extends JpaRepository<ServicoEntity, Long> {

    boolean existsByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCaseAndIdServicoNot(
            String nome,
            Long idServico
    );

    List<ServicoEntity> findByAtivoTrueOrderByNomeAsc();

    List<ServicoEntity> findAllByOrderByNomeAsc();


    List<ServicoEntity> findByDestaqueTrueAndAtivoTrueOrderByNomeAsc();

List<ServicoEntity> findDistinctByCategorias_CategoriaServico_IdCategoriaServicoOrderByNomeAsc(
        Long idCategoriaServico
);

List<ServicoEntity> findDistinctByCategorias_CategoriaServico_IdCategoriaServicoAndAtivoTrueOrderByNomeAsc(
        Long idCategoriaServico
);


}