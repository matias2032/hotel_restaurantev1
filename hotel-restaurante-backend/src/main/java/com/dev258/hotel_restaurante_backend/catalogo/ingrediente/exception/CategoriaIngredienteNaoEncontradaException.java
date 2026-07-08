package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.exception;

public class CategoriaIngredienteNaoEncontradaException extends RuntimeException {

    public CategoriaIngredienteNaoEncontradaException(Long idCategoriaIngrediente) {
        super("Categoria de ingrediente não encontrada. ID: " + idCategoriaIngrediente);
    }

    public CategoriaIngredienteNaoEncontradaException(String mensagem) {
        super(mensagem);
    }
}