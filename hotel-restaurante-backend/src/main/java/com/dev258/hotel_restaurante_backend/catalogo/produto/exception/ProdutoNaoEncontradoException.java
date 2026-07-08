package com.dev258.hotel_restaurante_backend.catalogo.produto.exception;

public class ProdutoNaoEncontradoException extends RuntimeException {

    public ProdutoNaoEncontradoException(Long idProduto) {
        super("Produto não encontrado. ID: " + idProduto);
    }

    public ProdutoNaoEncontradoException(String mensagem) {
        super(mensagem);
    }
}