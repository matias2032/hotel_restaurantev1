package com.dev258.hotel_restaurante_backend.catalogo.servico.controller;

import com.dev258.hotel_restaurante_backend.catalogo.servico.dto.CategoriaServicoRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.servico.dto.CategoriaServicoResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.servico.dto.ServicoRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.servico.dto.ServicoResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.servico.service.ServicoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/catalogo/servicos")
@RequiredArgsConstructor
public class ServicoController {

    private final ServicoService servicoService;

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — LISTAR
    // GET /api/catalogo/servicos/categorias
    // GET /api/catalogo/servicos/categorias?somenteAtivas=true
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/categorias")
    public List<CategoriaServicoResponseDTO> listarCategorias(
            @RequestParam(defaultValue = "false") Boolean somenteAtivas
    ) {
        return servicoService.listarCategorias(somenteAtivas);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — BUSCAR POR ID
    // GET /api/catalogo/servicos/categorias/{idCategoriaServico}
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/categorias/{idCategoriaServico}")
    public CategoriaServicoResponseDTO buscarCategoriaPorId(
            @PathVariable Long idCategoriaServico
    ) {
        return servicoService.buscarCategoriaPorId(idCategoriaServico);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — CRIAR
    // POST /api/catalogo/servicos/categorias
    // ─────────────────────────────────────────────────────────────

    @PostMapping("/categorias")
    @ResponseStatus(HttpStatus.CREATED)
    public CategoriaServicoResponseDTO criarCategoria(
            @Valid @RequestBody CategoriaServicoRequestDTO dto
    ) {
        return servicoService.criarCategoria(dto);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — EDITAR
    // PUT /api/catalogo/servicos/categorias/{idCategoriaServico}
    // ─────────────────────────────────────────────────────────────

    @PutMapping("/categorias/{idCategoriaServico}")
    public CategoriaServicoResponseDTO editarCategoria(
            @PathVariable Long idCategoriaServico,
            @Valid @RequestBody CategoriaServicoRequestDTO dto
    ) {
        return servicoService.editarCategoria(idCategoriaServico, dto);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — ALTERAR ESTADO
    // PATCH /api/catalogo/servicos/categorias/{idCategoriaServico}/estado
    // Body: { "ativo": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/categorias/{idCategoriaServico}/estado")
    public CategoriaServicoResponseDTO alterarEstadoCategoria(
            @PathVariable Long idCategoriaServico,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean ativo = body != null ? body.get("ativo") : null;

        return servicoService.alterarEstadoCategoria(
                idCategoriaServico,
                ativo
        );
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — DESATIVAR
    // DELETE /api/catalogo/servicos/categorias/{idCategoriaServico}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/categorias/{idCategoriaServico}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void desativarCategoria(
            @PathVariable Long idCategoriaServico
    ) {
        servicoService.desativarCategoria(idCategoriaServico);
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — LISTAR
    // GET /api/catalogo/servicos
    // GET /api/catalogo/servicos?somenteAtivos=true
    // GET /api/catalogo/servicos?somenteDisponiveis=true
    // GET /api/catalogo/servicos?somenteDestaques=true
    // GET /api/catalogo/servicos?idCategoriaServico=1
    // ─────────────────────────────────────────────────────────────

    @GetMapping
    public List<ServicoResponseDTO> listarServicos(
            @RequestParam(defaultValue = "false") Boolean somenteAtivos,
            @RequestParam(defaultValue = "false") Boolean somenteDisponiveis,
            @RequestParam(defaultValue = "false") Boolean somenteDestaques,
            @RequestParam(required = false) Long idCategoriaServico
    ) {
        return servicoService.listarServicos(
                somenteAtivos,
                somenteDisponiveis,
                somenteDestaques,
                idCategoriaServico
        );
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — BUSCAR POR ID
    // GET /api/catalogo/servicos/{idServico}
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/{idServico}")
    public ServicoResponseDTO buscarServicoPorId(
            @PathVariable Long idServico
    ) {
        return servicoService.buscarServicoPorId(idServico);
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — CRIAR
    // POST /api/catalogo/servicos
    // ─────────────────────────────────────────────────────────────

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ServicoResponseDTO criarServico(
            @Valid @RequestBody ServicoRequestDTO dto
    ) {
        return servicoService.criarServico(dto);
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — EDITAR
    // PUT /api/catalogo/servicos/{idServico}
    // ─────────────────────────────────────────────────────────────

    @PutMapping("/{idServico}")
    public ServicoResponseDTO editarServico(
            @PathVariable Long idServico,
            @Valid @RequestBody ServicoRequestDTO dto
    ) {
        return servicoService.editarServico(idServico, dto);
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — ALTERAR DISPONIBILIDADE
    // PATCH /api/catalogo/servicos/{idServico}/disponibilidade
    // Body: { "disponivel": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idServico}/disponibilidade")
    public ServicoResponseDTO alterarDisponibilidadeServico(
            @PathVariable Long idServico,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean disponivel = body != null ? body.get("disponivel") : null;

        return servicoService.alterarDisponibilidadeServico(
                idServico,
                disponivel
        );
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — ALTERAR DESTAQUE
    // PATCH /api/catalogo/servicos/{idServico}/destaque
    // Body: { "destaque": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idServico}/destaque")
    public ServicoResponseDTO alterarDestaqueServico(
            @PathVariable Long idServico,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean destaque = body != null ? body.get("destaque") : null;

        return servicoService.alterarDestaqueServico(
                idServico,
                destaque
        );
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — ALTERAR ESTADO
    // PATCH /api/catalogo/servicos/{idServico}/estado
    // Body: { "ativo": true }
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idServico}/estado")
    public ServicoResponseDTO alterarEstadoServico(
            @PathVariable Long idServico,
            @RequestBody Map<String, Boolean> body
    ) {
        Boolean ativo = body != null ? body.get("ativo") : null;

        return servicoService.alterarEstadoServico(
                idServico,
                ativo
        );
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — DESATIVAR
    // DELETE /api/catalogo/servicos/{idServico}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/{idServico}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void desativarServico(
            @PathVariable Long idServico
    ) {
        servicoService.desativarServico(idServico);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — LISTAR
    // GET /api/catalogo/servicos/{idServico}/imagens
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/{idServico}/imagens")
    public List<ServicoResponseDTO.ServicoImagemResponseDTO> listarImagensDoServico(
            @PathVariable Long idServico
    ) {
        return servicoService.listarImagensDoServico(idServico);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — ADICIONAR
    // POST /api/catalogo/servicos/{idServico}/imagens
    // ─────────────────────────────────────────────────────────────

    @PostMapping("/{idServico}/imagens")
    @ResponseStatus(HttpStatus.CREATED)
    public ServicoResponseDTO adicionarImagemAoServico(
            @PathVariable Long idServico,
            @Valid @RequestBody ServicoRequestDTO.ServicoImagemRequestDTO dto
    ) {
        return servicoService.adicionarImagemAoServico(
                idServico,
                dto
        );
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — DEFINIR PRINCIPAL
    // PATCH /api/catalogo/servicos/{idServico}/imagens/{idServicoImagem}/principal
    // ─────────────────────────────────────────────────────────────

    @PatchMapping("/{idServico}/imagens/{idServicoImagem}/principal")
    public ServicoResponseDTO definirImagemPrincipal(
            @PathVariable Long idServico,
            @PathVariable Long idServicoImagem
    ) {
        return servicoService.definirImagemPrincipal(
                idServico,
                idServicoImagem
        );
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — REMOVER
    // DELETE /api/catalogo/servicos/{idServico}/imagens/{idServicoImagem}
    // ─────────────────────────────────────────────────────────────

    @DeleteMapping("/{idServico}/imagens/{idServicoImagem}")
    public ServicoResponseDTO removerImagemDoServico(
            @PathVariable Long idServico,
            @PathVariable Long idServicoImagem
    ) {
        return servicoService.removerImagemDoServico(
                idServico,
                idServicoImagem
        );
    }
}