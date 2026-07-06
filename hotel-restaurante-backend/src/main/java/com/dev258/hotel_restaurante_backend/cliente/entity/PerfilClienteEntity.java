package com.dev258.hotel_restaurante_backend.cliente.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "perfil_cliente")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PerfilClienteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_perfil_cliente")
    private Long idPerfilCliente;

    @Column(name = "nome_perfil_cliente", nullable = false, unique = true, length = 120)
    private String nomePerfilCliente;
}