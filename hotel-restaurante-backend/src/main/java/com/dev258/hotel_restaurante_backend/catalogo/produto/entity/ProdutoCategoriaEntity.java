package com.dev258.hotel_restaurante_backend.catalogo.produto.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "produto_categoria")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProdutoCategoriaEntity {

    @EmbeddedId
    private ProdutoCategoriaId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idProduto")
    @JoinColumn(name = "id_produto", nullable = false)
    private ProdutoEntity produto;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("idCategoriaProduto")
    @JoinColumn(name = "id_categoria_produto", nullable = false)
    private CategoriaProdutoEntity categoriaProduto;

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
        if (produto == null || categoriaProduto == null) {
            return;
        }

        if (id == null) {
            id = new ProdutoCategoriaId();
        }

        id.setIdProduto(produto.getIdProduto());
        id.setIdCategoriaProduto(categoriaProduto.getIdCategoriaProduto());
    }
}