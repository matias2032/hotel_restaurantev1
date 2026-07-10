package com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.controller;

import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.dto.MovimentoEstoqueRequestDTO;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.dto.MovimentoEstoqueResponseDTO;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoItemEstoque;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoMovimentoEstoque;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.service.MovimentoEstoqueService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/administracao/movimentos-estoque")
@RequiredArgsConstructor
public class MovimentoEstoqueController {

    private final MovimentoEstoqueService movimentoEstoqueService;

    // ─────────────────────────────────────────────────────────────
    // LISTAR MOVIMENTOS
    // GET /api/administracao/movimentos-estoque
    // GET /api/administracao/movimentos-estoque?tipoItem=PRODUTO
    // GET /api/administracao/movimentos-estoque?tipoMovimento=ENTRADA
    // GET /api/administracao/movimentos-estoque?idProduto=1
    // GET /api/administracao/movimentos-estoque?idIngrediente=1
    // GET /api/administracao/movimentos-estoque?idUsuario=1
    // GET /api/administracao/movimentos-estoque?inicio=2026-07-01T00:00:00&fim=2026-07-31T23:59:59
    // ─────────────────────────────────────────────────────────────

    @GetMapping
    public List<MovimentoEstoqueResponseDTO> listarMovimentos(
            @RequestParam(required = false) TipoItemEstoque tipoItem,
            @RequestParam(required = false) TipoMovimentoEstoque tipoMovimento,
            @RequestParam(required = false) Long idProduto,
            @RequestParam(required = false) Long idIngrediente,
            @RequestParam(required = false) Long idUsuario,

            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime inicio,

            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime fim
    ) {
        return movimentoEstoqueService.listarMovimentos(
                tipoItem,
                tipoMovimento,
                idProduto,
                idIngrediente,
                idUsuario,
                inicio,
                fim
        );
    }

    // ─────────────────────────────────────────────────────────────
    // BUSCAR MOVIMENTO POR ID
    // GET /api/administracao/movimentos-estoque/{idMovimentoEstoque}
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/{idMovimentoEstoque}")
    public MovimentoEstoqueResponseDTO buscarPorId(
            @PathVariable Long idMovimentoEstoque
    ) {
        return movimentoEstoqueService.buscarPorId(idMovimentoEstoque);
    }

    // ─────────────────────────────────────────────────────────────
    // MOVIMENTAR ESTOQUE
    // POST /api/administracao/movimentos-estoque
    // ─────────────────────────────────────────────────────────────

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public MovimentoEstoqueResponseDTO movimentarEstoque(
            @Valid @RequestBody MovimentoEstoqueRequestDTO dto
    ) {
        return movimentoEstoqueService.movimentarEstoque(dto);
    }
}