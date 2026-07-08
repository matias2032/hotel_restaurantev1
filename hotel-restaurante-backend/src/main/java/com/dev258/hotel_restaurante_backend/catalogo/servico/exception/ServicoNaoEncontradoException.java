package com.dev258.hotel_restaurante_backend.catalogo.servico.exception;

public class ServicoNaoEncontradoException extends RuntimeException {

    public ServicoNaoEncontradoException(Long idServico) {
        super("Serviço não encontrado. ID: " + idServico);
    }

    public ServicoNaoEncontradoException(String mensagem) {
        super(mensagem);
    }
}