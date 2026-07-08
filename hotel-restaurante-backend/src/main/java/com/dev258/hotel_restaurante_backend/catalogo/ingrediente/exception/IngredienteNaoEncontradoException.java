package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.exception;

public class IngredienteNaoEncontradoException extends RuntimeException {

    public IngredienteNaoEncontradoException(Long idIngrediente) {
        super("Ingrediente não encontrado. ID: " + idIngrediente);
    }

    public IngredienteNaoEncontradoException(String mensagem) {
        super(mensagem);
    }
}