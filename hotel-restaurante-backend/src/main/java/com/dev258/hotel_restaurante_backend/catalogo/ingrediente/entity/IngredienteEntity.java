package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "ingrediente")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IngredienteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_ingrediente")
    private Long idIngrediente;

@OneToMany(
        mappedBy = "ingrediente",
        cascade = CascadeType.ALL,
        orphanRemoval = true
)
@OrderBy("principal DESC, ordem ASC")
@Builder.Default
private List<IngredienteCategoriaEntity> categorias = new ArrayList<>();

    @Column(name = "nome", nullable = false, length = 120)
    private String nome;

    @Column(name = "descricao", columnDefinition = "TEXT")
    private String descricao;

    @Column(name = "preco_adicional", nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal precoAdicional = BigDecimal.ZERO;

    @Column(name = "controla_estoque", nullable = false)
    @Builder.Default
    private Boolean controlaEstoque = false;

    @Column(name = "quantidade_estoque", precision = 12, scale = 3)
    private BigDecimal quantidadeEstoque;


    @Column(name = "ativo", nullable = false)
    @Builder.Default
    private Boolean ativo = true;

    @OneToMany(
            mappedBy = "ingrediente",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    @OrderBy("principal DESC, ordem ASC, idIngredienteImagem ASC")
    @Builder.Default
    private List<IngredienteImagemEntity> imagens = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public void adicionarImagem(IngredienteImagemEntity imagem) {
        if (imagem == null) {
            return;
        }

        imagem.setIngrediente(this);
        imagens.add(imagem);
    }

    public void adicionarCategoria(IngredienteCategoriaEntity categoria) {
    if (categoria == null) {
        return;
    }

    categoria.setIngrediente(this);
    categorias.add(categoria);
}

public void removerCategoria(IngredienteCategoriaEntity categoria) {
    if (categoria == null) {
        return;
    }

    categoria.setIngrediente(null);
    categorias.remove(categoria);
}

public void limparCategorias() {
    categorias.forEach(categoria -> categoria.setIngrediente(null));
    categorias.clear();
}

    public void removerImagem(IngredienteImagemEntity imagem) {
        if (imagem == null) {
            return;
        }

        imagem.setIngrediente(null);
        imagens.remove(imagem);
    }

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
        if (precoAdicional == null) {
            precoAdicional = BigDecimal.ZERO;
        }

        if (controlaEstoque == null) {
            controlaEstoque = false;
        }


        if (ativo == null) {
            ativo = true;
        }

        if (Boolean.FALSE.equals(controlaEstoque)) {
            quantidadeEstoque = null;
        }
    }
}