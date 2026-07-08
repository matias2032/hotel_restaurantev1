package com.dev258.hotel_restaurante_backend.catalogo.produto.controller;

import com.dev258.hotel_restaurante_backend.catalogo.produto.dto.CategoriaProdutoRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.produto.dto.CategoriaProdutoResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.produto.dto.ProdutoRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.produto.dto.ProdutoResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.produto.service.ProdutoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/catalogo/produtos")
@RequiredArgsConstructor
public class ProdutoController {

    private final ProdutoService produtoService;

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — LISTAR
    // GET /api/catalogo/produtos/categorias
    // GET /api/catalogo/produtos/categorias?somenteAtivas=true
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/categorias")
    public List<CategoriaProdutoResponseDTO> listarCategorias(
            @RequestParam(defaultValue = "false") Boolean somenteAtivas
    ) {
        return produtoService.listarCategorias(somenteAtivas);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — BUSCAR POR ID
    // GET /api/catalogo/produtos/categorias/{idCategoriaProduto}
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/categorias/{idCategoriaProduto}")
    public CategoriaProdutoResponseDTO buscarCategoriaPorId(
            @PathVariable Long idCategoriaProduto
    ) {
        return produtoService.buscarCategoriaPorId(idCategoriaProduto);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — CRIAR
    // POST /api/catalogo/produtos/categorias
    // ─────────────────────────────────────────────────────────────

    @PostMapping("/categorias")
    @ResponseStatus(HttpStatus.CREATED)
    public CategoriaProdutoResponseDTO criarCategoria(
            @Valid @RequestBody CategoriaProdutoRequestDTO dto
    ) {
        return produtoService.criarCategoria(dto);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — EDITAR
    // PUT /api/catalogo/produtos/categorias/{idCategoriaProduto}
    // ─────────────────────────────────────────────────────────────

    @PutMapping("/categorias/{idCategoriaProduto}")
    public CategoriaProdutoResponseDTO editarCategoria(
            @PathVariable Long idCategoriaProduto,
            @Valid @RequestBody CategoriaProdutoRequestDTO dto
    ) {
        return produtoService.editarCategoria(idCategoriaProduto, dto);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — ALTERAR ESTADO
    // PATCH /api/catalogo/produtos/categorias/{idCategoriaProduto}/estado
    // Body: { "ativo": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/categorias/{idCategoriaProduto}/estado")
    public CategoriaProdutoResponseDTO alterarEstadoCategoria(
            @PathVariable Long idCategoriaProduto,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean ativo = body != null ? body.get("ativo") : null;

        return produtoService.alterarEstadoCategoria(
                idCategoriaProduto,
                ativo
        );
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — DESATIVAR
    // DELETE /api/catalogo/produtos/categorias/{idCategoriaProduto}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/categorias/{idCategoriaProduto}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void desativarCategoria(
            @PathVariable Long idCategoriaProduto
    ) {
        produtoService.desativarCategoria(idCategoriaProduto);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — LISTAR
    // GET /api/catalogo/produtos
    // GET /api/catalogo/produtos?somenteAtivos=true
    // GET /api/catalogo/produtos?somenteDisponiveis=true
    // GET /api/catalogo/produtos?somenteDestaques=true
    // GET /api/catalogo/produtos?idCategoriaProduto=1
    // ─────────────────────────────────────────────────────────────

    @GetMapping
    public List<ProdutoResponseDTO> listarProdutos(
            @RequestParam(defaultValue = "false") Boolean somenteAtivos,
            @RequestParam(defaultValue = "false") Boolean somenteDisponiveis,
            @RequestParam(defaultValue = "false") Boolean somenteDestaques,
            @RequestParam(required = false) Long idCategoriaProduto
    ) {
        return produtoService.listarProdutos(
                somenteAtivos,
                somenteDisponiveis,
                somenteDestaques,
                idCategoriaProduto
        );
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — BUSCAR POR ID
    // GET /api/catalogo/produtos/{idProduto}
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/{idProduto}")
    public ProdutoResponseDTO buscarProdutoPorId(
            @PathVariable Long idProduto
    ) {
        return produtoService.buscarProdutoPorId(idProduto);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — CRIAR
    // POST /api/catalogo/produtos
    // ─────────────────────────────────────────────────────────────

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProdutoResponseDTO criarProduto(
            @Valid @RequestBody ProdutoRequestDTO dto
    ) {
        return produtoService.criarProduto(dto);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — EDITAR
    // PUT /api/catalogo/produtos/{idProduto}
    // ─────────────────────────────────────────────────────────────

    @PutMapping("/{idProduto}")
    public ProdutoResponseDTO editarProduto(
            @PathVariable Long idProduto,
            @Valid @RequestBody ProdutoRequestDTO dto
    ) {
        return produtoService.editarProduto(idProduto, dto);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — ALTERAR DISPONIBILIDADE
    // PATCH /api/catalogo/produtos/{idProduto}/disponibilidade
    // Body: { "disponivel": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idProduto}/disponibilidade")
    public ProdutoResponseDTO alterarDisponibilidadeProduto(
            @PathVariable Long idProduto,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean disponivel = body != null ? body.get("disponivel") : null;

        return produtoService.alterarDisponibilidadeProduto(
                idProduto,
                disponivel
        );
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — ALTERAR DESTAQUE
    // PATCH /api/catalogo/produtos/{idProduto}/destaque
    // Body: { "destaque": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idProduto}/destaque")
    public ProdutoResponseDTO alterarDestaqueProduto(
            @PathVariable Long idProduto,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean destaque = body != null ? body.get("destaque") : null;

        return produtoService.alterarDestaqueProduto(
                idProduto,
                destaque
        );
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — ALTERAR ESTADO
    // PATCH /api/catalogo/produtos/{idProduto}/estado
    // Body: { "ativo": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idProduto}/estado")
    public ProdutoResponseDTO alterarEstadoProduto(
            @PathVariable Long idProduto,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean ativo = body != null ? body.get("ativo") : null;

        return produtoService.alterarEstadoProduto(
                idProduto,
                ativo
        );
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — DESATIVAR
    // DELETE /api/catalogo/produtos/{idProduto}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/{idProduto}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void desativarProduto(
            @PathVariable Long idProduto
    ) {
        produtoService.desativarProduto(idProduto);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — LISTAR
    // GET /api/catalogo/produtos/{idProduto}/imagens
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/{idProduto}/imagens")
    public List<ProdutoResponseDTO.ProdutoImagemResponseDTO> listarImagensDoProduto(
            @PathVariable Long idProduto
    ) {
        return produtoService.listarImagensDoProduto(idProduto);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — ADICIONAR
    // POST /api/catalogo/produtos/{idProduto}/imagens
    // ─────────────────────────────────────────────────────────────

    @PostMapping("/{idProduto}/imagens")
    @ResponseStatus(HttpStatus.CREATED)
    public ProdutoResponseDTO adicionarImagemAoProduto(
            @PathVariable Long idProduto,
            @Valid @RequestBody ProdutoRequestDTO.ProdutoImagemRequestDTO dto
    ) {
        return produtoService.adicionarImagemAoProduto(
                idProduto,
                dto
        );
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — DEFINIR PRINCIPAL
    // PATCH /api/catalogo/produtos/{idProduto}/imagens/{idProdutoImagem}/principal
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idProduto}/imagens/{idProdutoImagem}/principal")
    public ProdutoResponseDTO definirImagemPrincipal(
            @PathVariable Long idProduto,
            @PathVariable Long idProdutoImagem
    ) {
        return produtoService.definirImagemPrincipal(
                idProduto,
                idProdutoImagem
        );
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — REMOVER
    // DELETE /api/catalogo/produtos/{idProduto}/imagens/{idProdutoImagem}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/{idProduto}/imagens/{idProdutoImagem}")
    public ProdutoResponseDTO removerImagemDoProduto(
            @PathVariable Long idProduto,
            @PathVariable Long idProdutoImagem
    ) {
        return produtoService.removerImagemDoProduto(
                idProduto,
                idProdutoImagem
        );
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES DO PRODUTO — LISTAR
    // GET /api/catalogo/produtos/{idProduto}/ingredientes
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/{idProduto}/ingredientes")
    public List<ProdutoResponseDTO.ProdutoIngredienteResponseDTO> listarIngredientesDoProduto(
            @PathVariable Long idProduto
    ) {
        return produtoService.listarIngredientesDoProduto(idProduto);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES DO PRODUTO — ADICIONAR
    // POST /api/catalogo/produtos/{idProduto}/ingredientes
    // ─────────────────────────────────────────────────────────────

    @PostMapping("/{idProduto}/ingredientes")
    @ResponseStatus(HttpStatus.CREATED)
    public ProdutoResponseDTO adicionarIngredienteAoProduto(
            @PathVariable Long idProduto,
            @Valid @RequestBody ProdutoRequestDTO.ProdutoIngredienteRequestDTO dto
    ) {
        return produtoService.adicionarIngredienteAoProduto(
                idProduto,
                dto
        );
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES DO PRODUTO — REMOVER
    // DELETE /api/catalogo/produtos/{idProduto}/ingredientes/{idIngrediente}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/{idProduto}/ingredientes/{idIngrediente}")
    public ProdutoResponseDTO removerIngredienteDoProduto(
            @PathVariable Long idProduto,
            @PathVariable Long idIngrediente
    ) {
        return produtoService.removerIngredienteDoProduto(
                idProduto,
                idIngrediente
        );
    }
}