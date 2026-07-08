package com.dev258.hotel_restaurante_backend.catalogo.produto.entity;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "produto_ingrediente")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProdutoIngredienteEntity {

    @EmbeddedId
    private ProdutoIngredienteId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idProduto")
    @JoinColumn(name = "id_produto", nullable = false)
    private ProdutoEntity produto;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idIngrediente")
    @JoinColumn(name = "id_ingrediente", nullable = false)
    private IngredienteEntity ingrediente;

    @Column(name = "obrigatorio", nullable = false)
    @Builder.Default
    private Boolean obrigatorio = false;

    @Column(name = "removivel", nullable = false)
    @Builder.Default
    private Boolean removivel = true;

    @Column(name = "permite_extra", nullable = false)
    @Builder.Default
    private Boolean permiteExtra = true;

    @Column(name = "quantidade_padrao", nullable = false, precision = 12, scale = 3)
    @Builder.Default
    private BigDecimal quantidadePadrao = BigDecimal.ONE;

    @PrePersist
    protected void prePersist() {
        normalizarDefaults();
        normalizarId();
    }

    @PreUpdate
    protected void preUpdate() {
        normalizarDefaults();
        normalizarId();
    }

    private void normalizarDefaults() {
        if (obrigatorio == null) {
            obrigatorio = false;
        }

        if (removivel == null) {
            removivel = true;
        }

        if (permiteExtra == null) {
            permiteExtra = true;
        }

        if (quantidadePadrao == null) {
            quantidadePadrao = BigDecimal.ONE;
        }
    }

    private void normalizarId() {
        if (id == null && produto != null && ingrediente != null) {
            id = ProdutoIngredienteId.builder()
                    .idProduto(produto.getIdProduto())
                    .idIngrediente(ingrediente.getIdIngrediente())
                    .build();
        }
    }
}