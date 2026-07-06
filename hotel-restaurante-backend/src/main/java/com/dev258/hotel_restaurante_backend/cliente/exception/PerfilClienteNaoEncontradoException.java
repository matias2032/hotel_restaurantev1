package com.dev258.hotel_restaurante_backend.cliente.exception;

public class PerfilClienteNaoEncontradoException extends RuntimeException {

    public PerfilClienteNaoEncontradoException(String mensagem) {
        super(mensagem);
    }

    public static PerfilClienteNaoEncontradoException porId(Long idPerfilCliente) {
        return new PerfilClienteNaoEncontradoException("Perfil de cliente não encontrado com id: " + idPerfilCliente);
    }
}