package com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity;

import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoEntity;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "movimento_estoque")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MovimentoEstoqueEntity {

    public enum TipoItemEstoque {
        PRODUTO,
        INGREDIENTE
    }

public enum TipoMovimentoEstoque {
    ENTRADA,
    SAIDA,
    AJUSTE,
    PERDA,
    CORRECAO,
    INVENTARIO,
    VENCIMENTO,
    OUTROS
}

    public enum OrigemMovimentoEstoque {
        MANUAL
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_movimento_estoque")
    private Long idMovimentoEstoque;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_item", nullable = false, length = 30)
    private TipoItemEstoque tipoItem;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_produto")
    private ProdutoEntity produto;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_ingrediente")
    private IngredienteEntity ingrediente;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_movimento", nullable = false, length = 40)
    private TipoMovimentoEstoque tipoMovimento;

    @Column(name = "motivo", nullable = false, length = 180)
    private String motivo;

    @Column(name = "observacoes", columnDefinition = "TEXT")
    private String observacoes;

    @Column(name = "quantidade_movimentada", nullable = false, precision = 12, scale = 3)
    private BigDecimal quantidadeMovimentada;

    @Column(name = "quantidade_anterior", nullable = false, precision = 12, scale = 3)
    private BigDecimal quantidadeAnterior;

    @Column(name = "quantidade_posterior", nullable = false, precision = 12, scale = 3)
    private BigDecimal quantidadePosterior;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_usuario", nullable = false)
    private UsuarioEntity usuario;

    @Enumerated(EnumType.STRING)
    @Column(name = "origem", nullable = false, length = 40)
    @Builder.Default
    private OrigemMovimentoEstoque origem = OrigemMovimentoEstoque.MANUAL;

    @Column(name = "movimentado_em", nullable = false)
    private LocalDateTime movimentadoEm;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void prePersist() {
        LocalDateTime agora = LocalDateTime.now();

        if (createdAt == null) {
            createdAt = agora;
        }

        if (movimentadoEm == null) {
            movimentadoEm = agora;
        }

        normalizarDefaults();
    }

    @PreUpdate
    protected void preUpdate() {
        normalizarDefaults();
    }

    private void normalizarDefaults() {
        if (origem == null) {
            origem = OrigemMovimentoEstoque.MANUAL;
        }

        if (quantidadeMovimentada == null) {
            quantidadeMovimentada = BigDecimal.ZERO;
        }

        if (quantidadeAnterior == null) {
            quantidadeAnterior = BigDecimal.ZERO;
        }

        if (quantidadePosterior == null) {
            quantidadePosterior = BigDecimal.ZERO;
        }
    }
}