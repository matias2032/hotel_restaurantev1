package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity;

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
public class IngredienteCategoriaId implements Serializable {

    @Column(name = "id_ingrediente")
    private Long idIngrediente;

    @Column(name = "id_categoria_ingrediente")
    private Long idCategoriaIngrediente;
}