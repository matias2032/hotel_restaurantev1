package com.dev258.hotel_restaurante_backend.catalogo.servico.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "categoria_servico")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategoriaServicoEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_categoria_servico")
    private Long idCategoriaServico;

    @Column(name = "nome", nullable = false, unique = true, length = 120)
    private String nome;

    @Column(name = "descricao", columnDefinition = "TEXT")
    private String descricao;

    @Column(name = "ordem", nullable = false)
    @Builder.Default
    private Integer ordem = 0;

    @Column(name = "ativo", nullable = false)
    @Builder.Default
    private Boolean ativo = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void prePersist() {
        LocalDateTime agora = LocalDateTime.now();

        if (createdAt == null) {
            createdAt = agora;
        }

        if (updatedAt == null) {
            updatedAt = agora;
        }

        normalizarDefaults();
    }

    @PreUpdate
    protected void preUpdate() {
        updatedAt = LocalDateTime.now();
        normalizarDefaults();
    }

    private void normalizarDefaults() {
        if (ordem == null) {
            ordem = 0;
        }

        if (ativo == null) {
            ativo = true;
        }
    }
}