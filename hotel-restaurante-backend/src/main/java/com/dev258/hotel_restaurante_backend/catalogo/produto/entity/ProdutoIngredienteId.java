package com.dev258.hotel_restaurante_backend.catalogo.produto.entity;

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
public class ProdutoIngredienteId implements Serializable {

    @Column(name = "id_produto")
    private Long idProduto;

    @Column(name = "id_ingrediente")
    private Long idIngrediente;
}