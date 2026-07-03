package com.dev258.hotel_restaurante_backend.administracao.usuario.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "usuario")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UsuarioEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_usuario")
    private Long idUsuario;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "id_perfil", nullable = false)
    private PerfilEntity perfil;

    @Column(name = "id_estabelecimento")
    private Long idEstabelecimento;

    @Column(name = "nome", nullable = false, length = 120)
    private String nome;

    @Column(name = "apelido", length = 120)
    private String apelido;

    @Column(name = "email", unique = true, length = 160)
    private String email;

    @Column(name = "telefone", length = 30)
    private String telefone;

    @Column(name = "senha_hash", nullable = false, length = 255)
    private String senhaHash;

    @Column(name = "primeira_senha", nullable = false)
    private Boolean primeiraSenha = true;

    @Column(name = "status", nullable = false)
    private Boolean status = true;

    @Column(name = "ultimo_login_at")
    private LocalDateTime ultimoLoginAt;

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
        if (status == null) {
            status = true;
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