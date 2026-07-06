package com.dev258.hotel_restaurante_backend.cliente.exception;

public class ClienteNaoEncontradoException extends RuntimeException {

    public ClienteNaoEncontradoException(String mensagem) {
        super(mensagem);
    }

    public static ClienteNaoEncontradoException porId(Long idCliente) {
        return new ClienteNaoEncontradoException("Cliente não encontrado com id: " + idCliente);
    }
}