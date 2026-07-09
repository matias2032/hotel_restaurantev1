package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "ingrediente_categoria")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IngredienteCategoriaEntity {

    @EmbeddedId
    private IngredienteCategoriaId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idIngrediente")
    @JoinColumn(name = "id_ingrediente", nullable = false)
    private IngredienteEntity ingrediente;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idCategoriaIngrediente")
    @JoinColumn(name = "id_categoria_ingrediente", nullable = false)
    private CategoriaIngredienteEntity categoriaIngrediente;

    @Column(name = "principal", nullable = false)
    @Builder.Default
    private Boolean principal = false;

    @Column(name = "ordem", nullable = false)
    @Builder.Default
    private Integer ordem = 0;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public IngredienteCategoriaEntity(
            IngredienteEntity ingrediente,
            CategoriaIngredienteEntity categoriaIngrediente,
            Boolean principal,
            Integer ordem
    ) {
        this.ingrediente = ingrediente;
        this.categoriaIngrediente = categoriaIngrediente;
        this.principal = principal != null ? principal : false;
        this.ordem = ordem != null ? ordem : 0;

        this.id = IngredienteCategoriaId.builder()
                .idIngrediente(
                        ingrediente != null ? ingrediente.getIdIngrediente() : null
                )
                .idCategoriaIngrediente(
                        categoriaIngrediente != null
                                ? categoriaIngrediente.getIdCategoriaIngrediente()
                                : null
                )
                .build();
    }

    @PrePersist
    protected void prePersist() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }

        normalizarDefaults();
        sincronizarId();
    }

    @PreUpdate
    protected void preUpdate() {
        normalizarDefaults();
        sincronizarId();
    }

    private void normalizarDefaults() {
        if (principal == null) {
            principal = false;
        }

        if (ordem == null) {
            ordem = 0;
        }
    }

    private void sincronizarId() {
        if (ingrediente == null || categoriaIngrediente == null) {
            return;
        }

        if (id == null) {
            id = new IngredienteCategoriaId();
        }

        id.setIdIngrediente(ingrediente.getIdIngrediente());
        id.setIdCategoriaIngrediente(
                categoriaIngrediente.getIdCategoriaIngrediente()
        );
    }
}