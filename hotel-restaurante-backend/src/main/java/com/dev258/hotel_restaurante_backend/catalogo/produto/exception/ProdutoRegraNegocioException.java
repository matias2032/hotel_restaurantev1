package com.dev258.hotel_restaurante_backend.catalogo.produto.exception;

public class ProdutoRegraNegocioException extends RuntimeException {

    public ProdutoRegraNegocioException(String mensagem) {
        super(mensagem);
    }
}