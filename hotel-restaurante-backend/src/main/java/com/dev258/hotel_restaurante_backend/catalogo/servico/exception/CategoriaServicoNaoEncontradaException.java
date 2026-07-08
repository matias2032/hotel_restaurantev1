package com.dev258.hotel_restaurante_backend.catalogo.servico.exception;

public class CategoriaServicoNaoEncontradaException extends RuntimeException {

    public CategoriaServicoNaoEncontradaException(Long idCategoriaServico) {
        super("Categoria de serviço não encontrada. ID: " + idCategoriaServico);
    }

    public CategoriaServicoNaoEncontradaException(String mensagem) {
        super(mensagem);
    }
}