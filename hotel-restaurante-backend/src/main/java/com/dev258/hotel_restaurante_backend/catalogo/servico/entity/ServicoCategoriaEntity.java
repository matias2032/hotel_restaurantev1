package com.dev258.hotel_restaurante_backend.catalogo.servico.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "servico_categoria")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServicoCategoriaEntity {

    @EmbeddedId
    private ServicoCategoriaId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idServico")
    @JoinColumn(name = "id_servico", nullable = false)
    private ServicoEntity servico;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idCategoriaServico")
    @JoinColumn(name = "id_categoria_servico", nullable = false)
    private CategoriaServicoEntity categoriaServico;

    @Column(name = "principal", nullable = false)
    @Builder.Default
    private Boolean principal = false;

    @Column(name = "ordem", nullable = false)
    @Builder.Default
    private Integer ordem = 0;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

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
        if (servico == null || categoriaServico == null) {
            return;
        }

        if (id == null) {
            id = new ServicoCategoriaId();
        }

        id.setIdServico(servico.getIdServico());
        id.setIdCategoriaServico(categoriaServico.getIdCategoriaServico());
    }
}