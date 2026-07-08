package com.dev258.hotel_restaurante_backend.catalogo.produto.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "produto_imagem")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProdutoImagemEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_produto_imagem")
    private Long idProdutoImagem;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_produto", nullable = false)
    private ProdutoEntity produto;

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