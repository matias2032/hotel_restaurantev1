package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.controller;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto.CategoriaIngredienteRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto.CategoriaIngredienteResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto.IngredienteRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto.IngredienteResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.service.IngredienteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/catalogo/ingredientes")
@RequiredArgsConstructor
public class IngredienteController {

    private final IngredienteService ingredienteService;

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — LISTAR
    // GET /api/catalogo/ingredientes/categorias
    // GET /api/catalogo/ingredientes/categorias?somenteAtivas=true
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/categorias")
    public List<CategoriaIngredienteResponseDTO> listarCategorias(
            @RequestParam(defaultValue = "false") Boolean somenteAtivas
    ) {
        return ingredienteService.listarCategorias(somenteAtivas);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — BUSCAR POR ID
    // GET /api/catalogo/ingredientes/categorias/{idCategoriaIngrediente}
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/categorias/{idCategoriaIngrediente}")
    public CategoriaIngredienteResponseDTO buscarCategoriaPorId(
            @PathVariable Long idCategoriaIngrediente
    ) {
        return ingredienteService.buscarCategoriaPorId(idCategoriaIngrediente);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — CRIAR
    // POST /api/catalogo/ingredientes/categorias
    // ─────────────────────────────────────────────────────────────

    @PostMapping("/categorias")
    @ResponseStatus(HttpStatus.CREATED)
    public CategoriaIngredienteResponseDTO criarCategoria(
            @Valid @RequestBody CategoriaIngredienteRequestDTO dto
    ) {
        return ingredienteService.criarCategoria(dto);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — EDITAR
    // PUT /api/catalogo/ingredientes/categorias/{idCategoriaIngrediente}
    // ─────────────────────────────────────────────────────────────

    @PutMapping("/categorias/{idCategoriaIngrediente}")
    public CategoriaIngredienteResponseDTO editarCategoria(
            @PathVariable Long idCategoriaIngrediente,
            @Valid @RequestBody CategoriaIngredienteRequestDTO dto
    ) {
        return ingredienteService.editarCategoria(idCategoriaIngrediente, dto);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — ALTERAR ESTADO
    // PATCH /api/catalogo/ingredientes/categorias/{idCategoriaIngrediente}/estado
    // Body: { "ativo": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/categorias/{idCategoriaIngrediente}/estado")
    public CategoriaIngredienteResponseDTO alterarEstadoCategoria(
            @PathVariable Long idCategoriaIngrediente,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean ativo = body != null ? body.get("ativo") : null;

        return ingredienteService.alterarEstadoCategoria(
                idCategoriaIngrediente,
                ativo
        );
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — DESATIVAR
    // DELETE /api/catalogo/ingredientes/categorias/{idCategoriaIngrediente}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/categorias/{idCategoriaIngrediente}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void desativarCategoria(
            @PathVariable Long idCategoriaIngrediente
    ) {
        ingredienteService.desativarCategoria(idCategoriaIngrediente);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — LISTAR
    // GET /api/catalogo/ingredientes
    // GET /api/catalogo/ingredientes?somenteAtivos=true
    // GET /api/catalogo/ingredientes?somenteDisponiveis=true
    // GET /api/catalogo/ingredientes?idCategoriaIngrediente=1
    // ─────────────────────────────────────────────────────────────

    @GetMapping
    public List<IngredienteResponseDTO> listarIngredientes(
            @RequestParam(defaultValue = "false") Boolean somenteAtivos,
            @RequestParam(defaultValue = "false") Boolean somenteDisponiveis,
            @RequestParam(required = false) Long idCategoriaIngrediente
    ) {
        return ingredienteService.listarIngredientes(
                somenteAtivos,
                somenteDisponiveis,
                idCategoriaIngrediente
        );
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — BUSCAR POR ID
    // GET /api/catalogo/ingredientes/{idIngrediente}
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/{idIngrediente}")
    public IngredienteResponseDTO buscarIngredientePorId(
            @PathVariable Long idIngrediente
    ) {
        return ingredienteService.buscarIngredientePorId(idIngrediente);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — CRIAR
    // POST /api/catalogo/ingredientes
    // ─────────────────────────────────────────────────────────────

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public IngredienteResponseDTO criarIngrediente(
            @Valid @RequestBody IngredienteRequestDTO dto
    ) {
        return ingredienteService.criarIngrediente(dto);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — EDITAR
    // PUT /api/catalogo/ingredientes/{idIngrediente}
    // ─────────────────────────────────────────────────────────────

    @PutMapping("/{idIngrediente}")
    public IngredienteResponseDTO editarIngrediente(
            @PathVariable Long idIngrediente,
            @Valid @RequestBody IngredienteRequestDTO dto
    ) {
        return ingredienteService.editarIngrediente(idIngrediente, dto);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — ALTERAR DISPONIBILIDADE
    // PATCH /api/catalogo/ingredientes/{idIngrediente}/disponibilidade
    // Body: { "disponivel": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idIngrediente}/disponibilidade")
    public IngredienteResponseDTO alterarDisponibilidadeIngrediente(
            @PathVariable Long idIngrediente,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean disponivel = body != null ? body.get("disponivel") : null;

        return ingredienteService.alterarDisponibilidadeIngrediente(
                idIngrediente,
                disponivel
        );
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — ALTERAR ESTADO
    // PATCH /api/catalogo/ingredientes/{idIngrediente}/estado
    // Body: { "ativo": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idIngrediente}/estado")
    public IngredienteResponseDTO alterarEstadoIngrediente(
            @PathVariable Long idIngrediente,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean ativo = body != null ? body.get("ativo") : null;

        return ingredienteService.alterarEstadoIngrediente(
                idIngrediente,
                ativo
        );
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — DESATIVAR
    // DELETE /api/catalogo/ingredientes/{idIngrediente}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/{idIngrediente}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void desativarIngrediente(
            @PathVariable Long idIngrediente
    ) {
        ingredienteService.desativarIngrediente(idIngrediente);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — LISTAR
    // GET /api/catalogo/ingredientes/{idIngrediente}/imagens
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/{idIngrediente}/imagens")
    public List<IngredienteResponseDTO.IngredienteImagemResponseDTO> listarImagensDoIngrediente(
            @PathVariable Long idIngrediente
    ) {
        return ingredienteService.listarImagensDoIngrediente(idIngrediente);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — ADICIONAR
    // POST /api/catalogo/ingredientes/{idIngrediente}/imagens
    // ─────────────────────────────────────────────────────────────

    @PostMapping("/{idIngrediente}/imagens")
    @ResponseStatus(HttpStatus.CREATED)
    public IngredienteResponseDTO adicionarImagemAoIngrediente(
            @PathVariable Long idIngrediente,
            @Valid @RequestBody IngredienteRequestDTO.IngredienteImagemRequestDTO dto
    ) {
        return ingredienteService.adicionarImagemAoIngrediente(
                idIngrediente,
                dto
        );
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — DEFINIR PRINCIPAL
    // PATCH /api/catalogo/ingredientes/{idIngrediente}/imagens/{idIngredienteImagem}/principal
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idIngrediente}/imagens/{idIngredienteImagem}/principal")
    public IngredienteResponseDTO definirImagemPrincipal(
            @PathVariable Long idIngrediente,
            @PathVariable Long idIngredienteImagem
    ) {
        return ingredienteService.definirImagemPrincipal(
                idIngrediente,
                idIngredienteImagem
        );
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — REMOVER
    // DELETE /api/catalogo/ingredientes/{idIngrediente}/imagens/{idIngredienteImagem}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/{idIngrediente}/imagens/{idIngredienteImagem}")
    public IngredienteResponseDTO removerImagemDoIngrediente(
            @PathVariable Long idIngrediente,
            @PathVariable Long idIngredienteImagem
    ) {
        return ingredienteService.removerImagemDoIngrediente(
                idIngrediente,
                idIngredienteImagem
        );
    }
}