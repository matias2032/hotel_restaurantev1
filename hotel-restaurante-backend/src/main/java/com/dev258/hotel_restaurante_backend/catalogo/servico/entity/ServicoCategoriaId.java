package com.dev258.hotel_restaurante_backend.catalogo.servico.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode
public class ServicoCategoriaId implements Serializable {

    @Column(name = "id_servico")
    private Long idServico;

    @Column(name = "id_categoria_servico")
    private Long idCategoriaServico;
}