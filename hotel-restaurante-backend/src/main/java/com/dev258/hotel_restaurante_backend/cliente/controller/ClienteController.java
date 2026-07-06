package com.dev258.hotel_restaurante_backend.cliente.controller;

import com.dev258.hotel_restaurante_backend.cliente.dto.*;
import com.dev258.hotel_restaurante_backend.cliente.service.ClienteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clientes")
@RequiredArgsConstructor
public class ClienteController {

    private final ClienteService clienteService;

    // =========================================================
    // PERFIL CLIENTE
    // =========================================================

    @PostMapping("/perfis")
    @ResponseStatus(HttpStatus.CREATED)
    public PerfilClienteResponseDTO criarPerfilCliente(@Valid @RequestBody PerfilClienteRequestDTO dto) {
        return clienteService.criarPerfilCliente(dto);
    }

    @GetMapping("/perfis")
    public List<PerfilClienteResponseDTO> listarPerfisCliente() {
        return clienteService.listarPerfisCliente();
    }

    @GetMapping("/perfis/{idPerfilCliente}")
    public PerfilClienteResponseDTO buscarPerfilClientePorId(@PathVariable Long idPerfilCliente) {
        return clienteService.buscarPerfilClientePorId(idPerfilCliente);
    }

    @PutMapping("/perfis/{idPerfilCliente}")
    public PerfilClienteResponseDTO editarPerfilCliente(
            @PathVariable Long idPerfilCliente,
            @Valid @RequestBody PerfilClienteRequestDTO dto
    ) {
        return clienteService.editarPerfilCliente(idPerfilCliente, dto);
    }

    // =========================================================
    // CLIENTE — AUTO-REGISTO (PÚBLICO, E-COMMERCE)
    // =========================================================

    @PostMapping("/registo")
    @ResponseStatus(HttpStatus.CREATED)
    public ClienteResponseDTO registarCliente(@Valid @RequestBody ClienteRegistoRequestDTO dto) {
        return clienteService.registarCliente(dto);
    }

    // =========================================================
    // CLIENTE — CADASTRO PELO ADMIN
    // =========================================================

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ClienteResponseDTO criarClienteAdmin(@Valid @RequestBody ClienteCreateRequestDTO dto) {
        return clienteService.criarClienteAdmin(dto);
    }

    // =========================================================
    // CLIENTE — CONSULTAS
    // =========================================================

    @GetMapping
    public List<ClienteResponseDTO> listarClientes(
            @RequestParam(name = "somenteAtivos", defaultValue = "false") boolean somenteAtivos
    ) {
        if (somenteAtivos) {
            return clienteService.listarClientesAtivos();
        }

        return clienteService.listarClientes();
    }

    @GetMapping("/resumo")
    public List<ClienteResumoDTO> listarClientesResumo() {
        return clienteService.listarClientesResumo();
    }

    @GetMapping("/{idCliente}")
    public ClienteResponseDTO buscarClientePorId(@PathVariable Long idCliente) {
        return clienteService.buscarClientePorId(idCliente);
    }

    // =========================================================
    // CLIENTE — EDIÇÃO E ESTADO
    // =========================================================

    @PutMapping("/{idCliente}")
    public ClienteResponseDTO editarCliente(
            @PathVariable Long idCliente,
            @Valid @RequestBody ClienteUpdateRequestDTO dto
    ) {
        return clienteService.editarCliente(idCliente, dto);
    }

    // @PatchMapping("/{idCliente}/ativo")
    // public ClienteResponseDTO alterarAtivoCliente(
    //         @PathVariable Long idCliente,
    //         @RequestParam Boolean ativo
    // ) {
    //     return clienteService.alterarAtivoCliente(idCliente, ativo);
    // }

    // =========================================================
    // CLIENTE — SENHA
    // =========================================================

    @PatchMapping("/{idCliente}/definir-senha")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void definirSenha(
            @PathVariable Long idCliente,
            @Valid @RequestBody DefinirSenhaClienteRequestDTO dto
    ) {
        clienteService.definirSenha(idCliente, dto);
    }

    @PatchMapping("/{idCliente}/senha")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void alterarSenha(
            @PathVariable Long idCliente,
            @Valid @RequestBody AlterarSenhaClienteRequestDTO dto
    ) {
        clienteService.alterarSenha(idCliente, dto);
    }

    @PatchMapping("/{idCliente}/primeira-senha")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void trocarPrimeiraSenha(
            @PathVariable Long idCliente,
            @Valid @RequestBody TrocarPrimeiraSenhaClienteRequestDTO dto
    ) {
        clienteService.trocarPrimeiraSenha(idCliente, dto);
    }

    // @PatchMapping("/{idCliente}/resetar-senha")
    // @ResponseStatus(HttpStatus.NO_CONTENT)
    // public void resetarSenhaPadrao(@PathVariable Long idCliente) {
    //     clienteService.resetarSenhaPadrao(idCliente);
    // }

    // =========================================================
    // CLIENTE — REMOÇÃO (SOFT DELETE)
    // =========================================================

    // @DeleteMapping("/{idCliente}")
    // @ResponseStatus(HttpStatus.NO_CONTENT)
    // public void eliminarCliente(@PathVariable Long idCliente) {
    //     clienteService.eliminarCliente(idCliente);
    // }
}