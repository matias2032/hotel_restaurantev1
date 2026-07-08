package com.dev258.hotel_restaurante_backend.catalogo.produto.exception;

public class CategoriaProdutoNaoEncontradaException extends RuntimeException {

    public CategoriaProdutoNaoEncontradaException(Long idCategoriaProduto) {
        super("Categoria de produto não encontrada. ID: " + idCategoriaProduto);
    }

    public CategoriaProdutoNaoEncontradaException(String mensagem) {
        super(mensagem);
    }
}