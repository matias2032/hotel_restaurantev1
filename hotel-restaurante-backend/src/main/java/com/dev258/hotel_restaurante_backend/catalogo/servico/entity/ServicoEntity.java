package com.dev258.hotel_restaurante_backend.catalogo.servico.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "servico")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServicoEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_servico")
    private Long idServico;

@OneToMany(
        mappedBy = "servico",
        cascade = CascadeType.ALL,
        orphanRemoval = true
)
@OrderBy("principal DESC, ordem ASC")
@Builder.Default
private List<ServicoCategoriaEntity> categorias = new ArrayList<>();

    @Column(name = "nome", nullable = false, length = 160)
    private String nome;

    @Column(name = "descricao", columnDefinition = "TEXT")
    private String descricao;

    @Column(name = "preco", nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal preco = BigDecimal.ZERO;

    @Column(name = "imagem_principal_url", columnDefinition = "TEXT")
    private String imagemPrincipalUrl;

    @Column(name = "disponivel", nullable = false)
    @Builder.Default
    private Boolean disponivel = true;

    @Column(name = "destaque", nullable = false)
    @Builder.Default
    private Boolean destaque = false;

    @Column(name = "ativo", nullable = false)
    @Builder.Default
    private Boolean ativo = true;

    @OneToMany(
            mappedBy = "servico",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    @OrderBy("principal DESC, ordem ASC, idServicoImagem ASC")
    @Builder.Default
    private List<ServicoImagemEntity> imagens = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public void adicionarCategoria(ServicoCategoriaEntity categoria) {
    if (categoria == null) {
        return;
    }

    categoria.setServico(this);
    categorias.add(categoria);
}

public void removerCategoria(ServicoCategoriaEntity categoria) {
    if (categoria == null) {
        return;
    }

    categoria.setServico(null);
    categorias.remove(categoria);
}

public void limparCategorias() {
    categorias.forEach(categoria -> categoria.setServico(null));
    categorias.clear();
}

    public void adicionarImagem(ServicoImagemEntity imagem) {
        if (imagem == null) {
            return;
        }

        imagem.setServico(this);
        imagens.add(imagem);
    }

    public void removerImagem(ServicoImagemEntity imagem) {
        if (imagem == null) {
            return;
        }

        imagem.setServico(null);
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
        if (preco == null) {
            preco = BigDecimal.ZERO;
        }

        if (disponivel == null) {
            disponivel = true;
        }

        if (destaque == null) {
            destaque = false;
        }

        if (ativo == null) {
            ativo = true;
        }
    }
}