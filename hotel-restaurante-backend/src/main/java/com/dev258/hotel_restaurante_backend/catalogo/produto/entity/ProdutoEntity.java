package com.dev258.hotel_restaurante_backend.catalogo.produto.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "produto")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProdutoEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_produto")
    private Long idProduto;

@OneToMany(
        mappedBy = "produto",
        cascade = CascadeType.ALL,
        orphanRemoval = true
)
@OrderBy("principal DESC, ordem ASC")
@Builder.Default
private List<ProdutoCategoriaEntity> categorias = new ArrayList<>();

    @Column(name = "nome", nullable = false, length = 160)
    private String nome;

    @Column(name = "descricao", columnDefinition = "TEXT")
    private String descricao;

@Column(name = "preco", nullable = false, precision = 12, scale = 2)
@Builder.Default
private BigDecimal preco = BigDecimal.ZERO;

@Column(name = "promocional", nullable = false)
@Builder.Default
private Boolean promocional = false;

@Column(name = "preco_promocional", precision = 12, scale = 2)
private BigDecimal precoPromocional;

@Column(name = "imagem_principal_url", columnDefinition = "TEXT")
private String imagemPrincipalUrl;

@Column(name = "controla_estoque", nullable = false)
@Builder.Default
private Boolean controlaEstoque = false;

@Column(name = "quantidade_estoque", precision = 12, scale = 3)
private BigDecimal quantidadeEstoque;

@Column(name = "controla_estoque_por_ingredientes", nullable = false)
@Builder.Default
private Boolean controlaEstoquePorIngredientes = false;

    @Column(name = "tempo_preparo_minutos")
    private Integer tempoPreparoMinutos;



    @Column(name = "destaque", nullable = false)
    @Builder.Default
    private Boolean destaque = false;

    @Column(name = "ativo", nullable = false)
    @Builder.Default
    private Boolean ativo = true;

    @OneToMany(
            mappedBy = "produto",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    @OrderBy("principal DESC, ordem ASC, idProdutoImagem ASC")
    @Builder.Default
    private List<ProdutoImagemEntity> imagens = new ArrayList<>();

    @OneToMany(
            mappedBy = "produto",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    @Builder.Default
    private List<ProdutoIngredienteEntity> ingredientes = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public void adicionarImagem(ProdutoImagemEntity imagem) {
        if (imagem == null) {
            return;
        }

        imagem.setProduto(this);
        imagens.add(imagem);
    }

    public void removerImagem(ProdutoImagemEntity imagem) {
        if (imagem == null) {
            return;
        }

        imagem.setProduto(null);
        imagens.remove(imagem);
    }

    public void adicionarIngrediente(ProdutoIngredienteEntity produtoIngrediente) {
        if (produtoIngrediente == null) {
            return;
        }

        produtoIngrediente.setProduto(this);
        ingredientes.add(produtoIngrediente);
    }

    public void removerIngrediente(ProdutoIngredienteEntity produtoIngrediente) {
        if (produtoIngrediente == null) {
            return;
        }

        produtoIngrediente.setProduto(null);
        ingredientes.remove(produtoIngrediente);
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

    public void adicionarCategoria(ProdutoCategoriaEntity categoria) {
    if (categoria == null) {
        return;
    }

    categoria.setProduto(this);
    categorias.add(categoria);
}

public void removerCategoria(ProdutoCategoriaEntity categoria) {
    if (categoria == null) {
        return;
    }

    categoria.setProduto(null);
    categorias.remove(categoria);
}

public void limparCategorias() {
    categorias.forEach(categoria -> categoria.setProduto(null));
    categorias.clear();
}

    private void normalizarDefaults() {
        if (preco == null) {
            preco = BigDecimal.ZERO;
        }

        if (promocional == null) {
            promocional = false;
        }

        if (Boolean.FALSE.equals(promocional)) {
            precoPromocional = null;
        }

        if (controlaEstoque == null) {
            controlaEstoque = false;
        }

        if (controlaEstoquePorIngredientes == null) {
            controlaEstoquePorIngredientes = false;
        }



        if (destaque == null) {
            destaque = false;
        }

        if (ativo == null) {
            ativo = true;
        }

        if (Boolean.FALSE.equals(controlaEstoque)) {
            quantidadeEstoque = null;
        }
    }
}