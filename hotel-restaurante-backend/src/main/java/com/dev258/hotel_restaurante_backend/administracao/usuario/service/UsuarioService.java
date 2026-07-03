package com.dev258.hotel_restaurante_backend.administracao.usuario.service;

import com.dev258.hotel_restaurante_backend.administracao.usuario.dto.*;
import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.PerfilEntity;
import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;
import com.dev258.hotel_restaurante_backend.administracao.usuario.repository.PerfilRepository;
import com.dev258.hotel_restaurante_backend.administracao.usuario.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class UsuarioService {

private static final Boolean STATUS_ATIVO = true;
private static final Boolean STATUS_INATIVO = false;
private static final String SENHA_PADRAO = "12345678";

    private final UsuarioRepository usuarioRepository;
    private final PerfilRepository perfilRepository;

    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // =========================================================
    // PERFIL
    // =========================================================

public PerfilResponseDTO criarPerfil(PerfilRequestDTO dto) {
    if (perfilRepository.existsByNomePerfilIgnoreCase(dto.nomePerfil())) {
        throw new IllegalArgumentException("Já existe um perfil com este nome.");
    }

    PerfilEntity perfil = PerfilEntity.builder()
            .nomePerfil(dto.nomePerfil().trim())
            .descricao(normalizarTextoOpcional(dto.descricao()))
            .status(dto.status() != null ? dto.status() : STATUS_ATIVO)
            .build();

    PerfilEntity salvo = perfilRepository.save(perfil);

    return PerfilResponseDTO.fromEntity(salvo);
}

    @Transactional(readOnly = true)
    public List<PerfilResponseDTO> listarPerfis() {
        return perfilRepository.findAllByOrderByNomePerfilAsc()
                .stream()
                .map(PerfilResponseDTO::fromEntity)
                .toList();
    }

@Transactional(readOnly = true)
public List<PerfilResponseDTO> listarPerfisAtivos() {
    return perfilRepository.findByStatusOrderByNomePerfilAsc(STATUS_ATIVO)
            .stream()
            .map(PerfilResponseDTO::fromEntity)
            .toList();
}

    @Transactional(readOnly = true)
    public PerfilResponseDTO buscarPerfilPorId(Long idPerfil) {
        PerfilEntity perfil = buscarPerfilEntity(idPerfil);
        return PerfilResponseDTO.fromEntity(perfil);
    }

public PerfilResponseDTO editarPerfil(Long idPerfil, PerfilRequestDTO dto) {
    PerfilEntity perfil = buscarPerfilEntity(idPerfil);

    perfilRepository.findByNomePerfilIgnoreCase(dto.nomePerfil())
            .filter(p -> !p.getIdPerfil().equals(idPerfil))
            .ifPresent(p -> {
                throw new IllegalArgumentException("Já existe outro perfil com este nome.");
            });

    perfil.setNomePerfil(dto.nomePerfil().trim());
    perfil.setDescricao(normalizarTextoOpcional(dto.descricao()));

    if (dto.status() != null) {
        perfil.setStatus(dto.status());
    }

    PerfilEntity salvo = perfilRepository.save(perfil);

    return PerfilResponseDTO.fromEntity(salvo);
}

public PerfilResponseDTO alterarStatusPerfil(Long idPerfil, Boolean status) {
    validarStatusObrigatorio(status);

    PerfilEntity perfil = buscarPerfilEntity(idPerfil);
    perfil.setStatus(status);

    PerfilEntity salvo = perfilRepository.save(perfil);

    return PerfilResponseDTO.fromEntity(salvo);
}

    // =========================================================
    // USUÁRIO
    // =========================================================

    public UsuarioResponseDTO criarUsuario(UsuarioCreateRequestDTO dto) {
        String emailNormalizado = normalizarTextoOpcional(dto.email());

        if (emailNormalizado != null && usuarioRepository.existsByEmailIgnoreCase(emailNormalizado)) {
            throw new IllegalArgumentException("Já existe um usuário com este email.");
        }

        PerfilEntity perfil = buscarPerfilEntity(dto.idPerfil());

    UsuarioEntity usuario = UsuarioEntity.builder()
        .perfil(perfil)
        .idEstabelecimento(dto.idEstabelecimento())
        .nome(dto.nome().trim())
        .apelido(normalizarTextoOpcional(dto.apelido()))
        .email(emailNormalizado)
        .telefone(normalizarTextoOpcional(dto.telefone()))
        .senhaHash(passwordEncoder.encode(SENHA_PADRAO))
        .primeiraSenha(true)
        .status(STATUS_ATIVO)
        .build();

        UsuarioEntity salvo = usuarioRepository.save(usuario);

        return UsuarioResponseDTO.fromEntity(salvo);
    }

    @Transactional(readOnly = true)
    public List<UsuarioResumoDTO> listarUsuariosResumo() {
        return usuarioRepository.findAllByOrderByNomeAsc()
                .stream()
                .map(UsuarioResumoDTO::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<UsuarioResponseDTO> listarUsuarios() {
        return usuarioRepository.findAllByOrderByNomeAsc()
                .stream()
                .map(UsuarioResponseDTO::fromEntity)
                .toList();
    }

@Transactional(readOnly = true)
public List<UsuarioResponseDTO> listarUsuariosAtivos() {
    return usuarioRepository.findByStatusOrderByNomeAsc(STATUS_ATIVO)
            .stream()
            .map(UsuarioResponseDTO::fromEntity)
            .toList();
}

    @Transactional(readOnly = true)
    public UsuarioResponseDTO buscarUsuarioPorId(Long idUsuario) {
        UsuarioEntity usuario = buscarUsuarioEntity(idUsuario);
        return UsuarioResponseDTO.fromEntity(usuario);
    }

public UsuarioResponseDTO editarUsuario(Long idUsuario, UsuarioUpdateRequestDTO dto) {
    UsuarioEntity usuario = buscarUsuarioEntity(idUsuario);
    PerfilEntity perfil = buscarPerfilEntity(dto.idPerfil());

    String emailNormalizado = normalizarTextoOpcional(dto.email());

    if (emailNormalizado != null) {
        usuarioRepository.findByEmailIgnoreCase(emailNormalizado)
                .filter(u -> !u.getIdUsuario().equals(idUsuario))
                .ifPresent(u -> {
                    throw new IllegalArgumentException("Já existe outro usuário com este email.");
                });
    }

    usuario.setPerfil(perfil);
    usuario.setIdEstabelecimento(dto.idEstabelecimento());

    if (dto.nome() != null && !dto.nome().isBlank()) {
        usuario.setNome(dto.nome().trim());
    }

    usuario.setApelido(normalizarTextoOpcional(dto.apelido()));
    usuario.setEmail(emailNormalizado);
    usuario.setTelefone(normalizarTextoOpcional(dto.telefone()));

    if (dto.status() != null) {
        usuario.setStatus(dto.status());
    }

    UsuarioEntity salvo = usuarioRepository.save(usuario);

    return UsuarioResponseDTO.fromEntity(salvo);
}

public UsuarioResponseDTO alterarStatusUsuario(Long idUsuario, Boolean status) {
    validarStatusObrigatorio(status);

    UsuarioEntity usuario = buscarUsuarioEntity(idUsuario);
    usuario.setStatus(status);

    UsuarioEntity salvo = usuarioRepository.save(usuario);

    return UsuarioResponseDTO.fromEntity(salvo);
}
public void alterarSenha(Long idUsuario, AlterarSenhaRequestDTO dto) {
    UsuarioEntity usuario = buscarUsuarioEntity(idUsuario);

    boolean senhaActualConfere = passwordEncoder.matches(
            dto.senhaActual(),
            usuario.getSenhaHash()
    );

    if (!senhaActualConfere) {
        throw new IllegalArgumentException("A senha actual está incorrecta.");
    }

    usuario.setSenhaHash(passwordEncoder.encode(dto.novaSenha()));
    usuario.setPrimeiraSenha(false);

    usuarioRepository.save(usuario);
}

public void resetarSenhaPadrao(Long idUsuario) {
    UsuarioEntity usuario = buscarUsuarioEntity(idUsuario);

    usuario.setSenhaHash(passwordEncoder.encode(SENHA_PADRAO));
    usuario.setPrimeiraSenha(true);

    usuarioRepository.save(usuario);
}

public void trocarPrimeiraSenha(Long idUsuario, TrocarPrimeiraSenhaRequestDTO dto) {
    UsuarioEntity usuario = buscarUsuarioEntity(idUsuario);

    if (usuario.getPrimeiraSenha() == null || !usuario.getPrimeiraSenha()) {
        throw new IllegalArgumentException("Este usuário já alterou a primeira senha.");
    }

    usuario.setSenhaHash(passwordEncoder.encode(dto.novaSenha()));
    usuario.setPrimeiraSenha(false);

    usuarioRepository.save(usuario);
}

 public void eliminarUsuario(Long idUsuario) {
    UsuarioEntity usuario = buscarUsuarioEntity(idUsuario);
    usuario.setStatus(STATUS_INATIVO);
    usuarioRepository.save(usuario);
}
    // =========================================================
    // MÉTODOS INTERNOS
    // =========================================================

    private PerfilEntity buscarPerfilEntity(Long idPerfil) {
        return perfilRepository.findById(idPerfil)
                .orElseThrow(() -> new IllegalArgumentException("Perfil não encontrado."));
    }

    private UsuarioEntity buscarUsuarioEntity(Long idUsuario) {
        return usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado."));
    }

    private String normalizarTextoOpcional(String valor) {
        if (valor == null) {
            return null;
        }

        String texto = valor.trim();
        return texto.isBlank() ? null : texto;
    }

 

private void validarStatusObrigatorio(Boolean status) {
    if (status == null) {
        throw new IllegalArgumentException("Status é obrigatório.");
    }
}
}