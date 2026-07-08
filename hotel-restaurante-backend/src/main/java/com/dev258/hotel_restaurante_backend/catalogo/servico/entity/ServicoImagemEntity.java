package com.dev258.hotel_restaurante_backend.catalogo.servico.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "servico_imagem")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServicoImagemEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_servico_imagem")
    private Long idServicoImagem;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_servico", nullable = false)
    private ServicoEntity servico;

    @Column(name = "imagem_url", nullable = false, columnDefinition = "TEXT")
    private String imagemUrl;

    @Column(name = "legenda", length = 160)
    private String legenda;

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
    }

    @PreUpdate
    protected void preUpdate() {
        normalizarDefaults();
    }

    private void normalizarDefaults() {
        if (principal == null) {
            principal = false;
        }

        if (ordem == null) {
            ordem = 0;
        }
    }
}