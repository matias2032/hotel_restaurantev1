package com.dev258.hotel_restaurante_backend.administracao.usuario.controller;

import com.dev258.hotel_restaurante_backend.administracao.usuario.dto.*;
import com.dev258.hotel_restaurante_backend.administracao.usuario.service.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/administracao/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    // =========================================================
    // PERFIS
    // =========================================================

    @PostMapping("/perfis")
    @ResponseStatus(HttpStatus.CREATED)
    public PerfilResponseDTO criarPerfil(@Valid @RequestBody PerfilRequestDTO dto) {
        return usuarioService.criarPerfil(dto);
    }

    @GetMapping("/perfis")
    public List<PerfilResponseDTO> listarPerfis(
            @RequestParam(name = "somenteAtivos", defaultValue = "false") boolean somenteAtivos
    ) {
        if (somenteAtivos) {
            return usuarioService.listarPerfisAtivos();
        }

        return usuarioService.listarPerfis();
    }

    @GetMapping("/perfis/{idPerfil}")
    public PerfilResponseDTO buscarPerfilPorId(@PathVariable Long idPerfil) {
        return usuarioService.buscarPerfilPorId(idPerfil);
    }

    @PutMapping("/perfis/{idPerfil}")
    public PerfilResponseDTO editarPerfil(
            @PathVariable Long idPerfil,
            @Valid @RequestBody PerfilRequestDTO dto
    ) {
        return usuarioService.editarPerfil(idPerfil, dto);
    }

    @PatchMapping("/perfis/{idPerfil}/status")
    public PerfilResponseDTO alterarStatusPerfil(
            @PathVariable Long idPerfil,
            @RequestParam Boolean status
    ) {
        return usuarioService.alterarStatusPerfil(idPerfil, status);
    }

    // =========================================================
    // USUÁRIOS
    // =========================================================

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UsuarioResponseDTO criarUsuario(@Valid @RequestBody UsuarioCreateRequestDTO dto) {
        return usuarioService.criarUsuario(dto);
    }

    @GetMapping
    public List<UsuarioResponseDTO> listarUsuarios(
            @RequestParam(name = "somenteAtivos", defaultValue = "false") boolean somenteAtivos
    ) {
        if (somenteAtivos) {
            return usuarioService.listarUsuariosAtivos();
        }

        return usuarioService.listarUsuarios();
    }

    @GetMapping("/resumo")
    public List<UsuarioResumoDTO> listarUsuariosResumo() {
        return usuarioService.listarUsuariosResumo();
    }

    @GetMapping("/{idUsuario}")
    public UsuarioResponseDTO buscarUsuarioPorId(@PathVariable Long idUsuario) {
        return usuarioService.buscarUsuarioPorId(idUsuario);
    }

    @PutMapping("/{idUsuario}")
    public UsuarioResponseDTO editarUsuario(
            @PathVariable Long idUsuario,
            @Valid @RequestBody UsuarioUpdateRequestDTO dto
    ) {
        return usuarioService.editarUsuario(idUsuario, dto);
    }

    @PatchMapping("/{idUsuario}/status")
    public UsuarioResponseDTO alterarStatusUsuario(
            @PathVariable Long idUsuario,
            @RequestParam Boolean status
    ) {
        return usuarioService.alterarStatusUsuario(idUsuario, status);
    }

    @PatchMapping("/{idUsuario}/senha")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void alterarSenha(
            @PathVariable Long idUsuario,
            @Valid @RequestBody AlterarSenhaRequestDTO dto
    ) {
        usuarioService.alterarSenha(idUsuario, dto);
    }

    @PatchMapping("/{idUsuario}/primeira-senha")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void trocarPrimeiraSenha(
            @PathVariable Long idUsuario,
            @Valid @RequestBody TrocarPrimeiraSenhaRequestDTO dto
    ) {
        usuarioService.trocarPrimeiraSenha(idUsuario, dto);
    }

    @PatchMapping("/{idUsuario}/resetar-senha")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void resetarSenhaPadrao(@PathVariable Long idUsuario) {
        usuarioService.resetarSenhaPadrao(idUsuario);
    }

    @DeleteMapping("/{idUsuario}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminarUsuario(@PathVariable Long idUsuario) {
        usuarioService.eliminarUsuario(idUsuario);
    }
}