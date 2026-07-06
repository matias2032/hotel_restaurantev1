package com.dev258.hotel_restaurante_backend.cliente.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "cliente")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClienteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_cliente")
    private Long idCliente;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_perfil_cliente", nullable = false)
    private PerfilClienteEntity perfilCliente;

    @Column(name = "nome", nullable = false, length = 120)
    private String nome;

    @Column(name = "apelido", length = 120)
    private String apelido;

    @Column(name = "email", unique = true, length = 160)
    private String email;

    @Column(name = "telefone", length = 30)
    private String telefone;

    @Column(name = "nuit", length = 30)
    private String nuit;

    @Column(name = "senha_hash", length = 255)
    private String senhaHash;

    @Column(name = "ativo", nullable = false)
    private Boolean ativo = true;

    
@Column(name = "primeira_senha", nullable = false)
private Boolean primeiraSenha = true;


    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        LocalDateTime agora = LocalDateTime.now();
        if (createdAt == null) {
            createdAt = agora;
        }
        if (updatedAt == null) {
            updatedAt = agora;
        }
        if (ativo == null) {
            ativo = true;
        }

         if (primeiraSenha == null) {
            primeiraSenha = true;
        }
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}