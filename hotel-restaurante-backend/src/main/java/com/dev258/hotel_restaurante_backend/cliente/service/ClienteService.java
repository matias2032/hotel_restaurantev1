package com.dev258.hotel_restaurante_backend.cliente.service;

import com.dev258.hotel_restaurante_backend.cliente.dto.*;
import com.dev258.hotel_restaurante_backend.cliente.entity.ClienteEntity;
import com.dev258.hotel_restaurante_backend.cliente.entity.PerfilClienteEntity;
import com.dev258.hotel_restaurante_backend.cliente.exception.ClienteNaoEncontradoException;
import com.dev258.hotel_restaurante_backend.cliente.exception.PerfilClienteNaoEncontradoException;
import com.dev258.hotel_restaurante_backend.cliente.repository.ClienteRepository;
import com.dev258.hotel_restaurante_backend.cliente.repository.PerfilClienteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ClienteService {

    private static final Boolean ATIVO = true;
    private static final Boolean INATIVO = false;
    private static final String SENHA_PADRAO = "12345678";
    private static final String PERFIL_CLIENTE_PADRAO = "singular";

    private final ClienteRepository clienteRepository;
    private final PerfilClienteRepository perfilClienteRepository;

    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // =========================================================
    // PERFIL CLIENTE
    // =========================================================

    public PerfilClienteResponseDTO criarPerfilCliente(PerfilClienteRequestDTO dto) {
        if (perfilClienteRepository.existsByNomePerfilClienteIgnoreCase(dto.nomePerfilCliente())) {
            throw new IllegalArgumentException("Já existe um perfil de cliente com este nome.");
        }

        PerfilClienteEntity perfil = PerfilClienteEntity.builder()
                .nomePerfilCliente(dto.nomePerfilCliente().trim())
                .build();

        PerfilClienteEntity salvo = perfilClienteRepository.save(perfil);

        return PerfilClienteResponseDTO.fromEntity(salvo);
    }

    @Transactional(readOnly = true)
    public List<PerfilClienteResponseDTO> listarPerfisCliente() {
        return perfilClienteRepository.findAllByOrderByNomePerfilClienteAsc()
                .stream()
                .map(PerfilClienteResponseDTO::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public PerfilClienteResponseDTO buscarPerfilClientePorId(Long idPerfilCliente) {
        PerfilClienteEntity perfil = buscarPerfilClienteEntity(idPerfilCliente);
        return PerfilClienteResponseDTO.fromEntity(perfil);
    }

    public PerfilClienteResponseDTO editarPerfilCliente(Long idPerfilCliente, PerfilClienteRequestDTO dto) {
        PerfilClienteEntity perfil = buscarPerfilClienteEntity(idPerfilCliente);

        perfilClienteRepository.findByNomePerfilClienteIgnoreCase(dto.nomePerfilCliente())
                .filter(p -> !p.getIdPerfilCliente().equals(idPerfilCliente))
                .ifPresent(p -> {
                    throw new IllegalArgumentException("Já existe outro perfil de cliente com este nome.");
                });

        perfil.setNomePerfilCliente(dto.nomePerfilCliente().trim());

        PerfilClienteEntity salvo = perfilClienteRepository.save(perfil);

        return PerfilClienteResponseDTO.fromEntity(salvo);
    }

    // =========================================================
    // CLIENTE — AUTO-REGISTO (E-COMMERCE)
    // =========================================================

    public ClienteResponseDTO registarCliente(ClienteRegistoRequestDTO dto) {
        String emailNormalizado = normalizarTextoOpcional(dto.email());

        if (emailNormalizado != null && clienteRepository.existsByEmailIgnoreCase(emailNormalizado)) {
            throw new IllegalArgumentException("Já existe um cliente com este email.");
        }

        if (!dto.senha().equals(dto.confirmarSenha())) {
            throw new IllegalArgumentException("A senha e a confirmação de senha não conferem.");
        }

        PerfilClienteEntity perfilPadrao = perfilClienteRepository
                .findByNomePerfilClienteIgnoreCase(PERFIL_CLIENTE_PADRAO)
                .orElseThrow(() -> new IllegalStateException(
                        "Perfil de cliente padrão '" + PERFIL_CLIENTE_PADRAO + "' não está configurado."));

        ClienteEntity cliente = ClienteEntity.builder()
                .perfilCliente(perfilPadrao)
                .nome(dto.nome().trim())
                .apelido(normalizarTextoOpcional(dto.apelido()))
                .email(emailNormalizado)
                .telefone(normalizarTextoOpcional(dto.telefone()))
                .senhaHash(passwordEncoder.encode(dto.senha()))
                .primeiraSenha(false)
                .ativo(ATIVO)
                .build();

        ClienteEntity salvo = clienteRepository.save(cliente);

        return ClienteResponseDTO.fromEntity(salvo);
    }

    // =========================================================
    // CLIENTE — CADASTRO PELO ADMIN
    // =========================================================

    public ClienteResponseDTO criarClienteAdmin(ClienteCreateRequestDTO dto) {
        String emailNormalizado = normalizarTextoOpcional(dto.email());

        if (emailNormalizado != null && clienteRepository.existsByEmailIgnoreCase(emailNormalizado)) {
            throw new IllegalArgumentException("Já existe um cliente com este email.");
        }

        PerfilClienteEntity perfil = buscarPerfilClienteEntity(dto.idPerfilCliente());

        ClienteEntity cliente = ClienteEntity.builder()
                .perfilCliente(perfil)
                .nome(dto.nome().trim())
                .apelido(normalizarTextoOpcional(dto.apelido()))
                .email(emailNormalizado)
                .telefone(normalizarTextoOpcional(dto.telefone()))
                .nuit(normalizarTextoOpcional(dto.nuit()))
                .senhaHash(passwordEncoder.encode(SENHA_PADRAO))
                .primeiraSenha(true)
                .ativo(ATIVO)
                .build();

        ClienteEntity salvo = clienteRepository.save(cliente);

        return ClienteResponseDTO.fromEntity(salvo);
    }

    // =========================================================
    // CLIENTE — CONSULTAS
    // =========================================================

    @Transactional(readOnly = true)
    public List<ClienteResumoDTO> listarClientesResumo() {
        return clienteRepository.findAllByOrderByNomeAsc()
                .stream()
                .map(ClienteResumoDTO::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ClienteResponseDTO> listarClientes() {
        return clienteRepository.findAllByOrderByNomeAsc()
                .stream()
                .map(ClienteResponseDTO::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ClienteResponseDTO> listarClientesAtivos() {
        return clienteRepository.findByAtivoOrderByNomeAsc(ATIVO)
                .stream()
                .map(ClienteResponseDTO::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public ClienteResponseDTO buscarClientePorId(Long idCliente) {
        ClienteEntity cliente = buscarClienteEntity(idCliente);
        return ClienteResponseDTO.fromEntity(cliente);
    }

    // =========================================================
    // CLIENTE — EDIÇÃO E ESTADO
    // =========================================================

    public ClienteResponseDTO editarCliente(Long idCliente, ClienteUpdateRequestDTO dto) {
        ClienteEntity cliente = buscarClienteEntity(idCliente);
        PerfilClienteEntity perfil = buscarPerfilClienteEntity(dto.idPerfilCliente());

        String emailNormalizado = normalizarTextoOpcional(dto.email());

        if (emailNormalizado != null) {
            clienteRepository.findByEmailIgnoreCase(emailNormalizado)
                    .filter(c -> !c.getIdCliente().equals(idCliente))
                    .ifPresent(c -> {
                        throw new IllegalArgumentException("Já existe outro cliente com este email.");
                    });
        }

        cliente.setPerfilCliente(perfil);

        if (dto.nome() != null && !dto.nome().isBlank()) {
            cliente.setNome(dto.nome().trim());
        }

        cliente.setApelido(normalizarTextoOpcional(dto.apelido()));
        cliente.setEmail(emailNormalizado);
        cliente.setTelefone(normalizarTextoOpcional(dto.telefone()));
        cliente.setNuit(normalizarTextoOpcional(dto.nuit()));

        if (dto.ativo() != null) {
            cliente.setAtivo(dto.ativo());
        }

        ClienteEntity salvo = clienteRepository.save(cliente);

        return ClienteResponseDTO.fromEntity(salvo);
    }

    public ClienteResponseDTO alterarAtivoCliente(Long idCliente, Boolean ativo) {
        validarAtivoObrigatorio(ativo);

        ClienteEntity cliente = buscarClienteEntity(idCliente);
        cliente.setAtivo(ativo);

        ClienteEntity salvo = clienteRepository.save(cliente);

        return ClienteResponseDTO.fromEntity(salvo);
    }

    // =========================================================
    // CLIENTE — SENHA
    // =========================================================

    public void definirSenha(Long idCliente, DefinirSenhaClienteRequestDTO dto) {
        ClienteEntity cliente = buscarClienteEntity(idCliente);

        if (cliente.getSenhaHash() != null) {
            throw new IllegalArgumentException("Este cliente já possui uma senha definida.");
        }

        cliente.setSenhaHash(passwordEncoder.encode(dto.novaSenha()));
        cliente.setPrimeiraSenha(false);

        clienteRepository.save(cliente);
    }

    public void alterarSenha(Long idCliente, AlterarSenhaClienteRequestDTO dto) {
        ClienteEntity cliente = buscarClienteEntity(idCliente);

        if (cliente.getSenhaHash() == null) {
            throw new IllegalArgumentException("Este cliente ainda não possui senha definida.");
        }

        boolean senhaActualConfere = passwordEncoder.matches(
                dto.senhaActual(),
                cliente.getSenhaHash()
        );

        if (!senhaActualConfere) {
            throw new IllegalArgumentException("A senha actual está incorrecta.");
        }

        cliente.setSenhaHash(passwordEncoder.encode(dto.novaSenha()));
        cliente.setPrimeiraSenha(false);

        clienteRepository.save(cliente);
    }

    public void trocarPrimeiraSenha(Long idCliente, TrocarPrimeiraSenhaClienteRequestDTO dto) {
        ClienteEntity cliente = buscarClienteEntity(idCliente);

        if (cliente.getPrimeiraSenha() == null || !cliente.getPrimeiraSenha()) {
            throw new IllegalArgumentException("Este cliente já alterou a primeira senha.");
        }

        cliente.setSenhaHash(passwordEncoder.encode(dto.novaSenha()));
        cliente.setPrimeiraSenha(false);

        clienteRepository.save(cliente);
    }

    public void resetarSenhaPadrao(Long idCliente) {
        ClienteEntity cliente = buscarClienteEntity(idCliente);

        cliente.setSenhaHash(passwordEncoder.encode(SENHA_PADRAO));
        cliente.setPrimeiraSenha(true);

        clienteRepository.save(cliente);
    }

    // =========================================================
    // CLIENTE — REMOÇÃO (SOFT DELETE)
    // =========================================================

    public void eliminarCliente(Long idCliente) {
        ClienteEntity cliente = buscarClienteEntity(idCliente);
        cliente.setAtivo(INATIVO);
        clienteRepository.save(cliente);
    }

    // =========================================================
    // MÉTODOS INTERNOS
    // =========================================================

    private PerfilClienteEntity buscarPerfilClienteEntity(Long idPerfilCliente) {
        return perfilClienteRepository.findById(idPerfilCliente)
                .orElseThrow(() -> PerfilClienteNaoEncontradoException.porId(idPerfilCliente));
    }

    private ClienteEntity buscarClienteEntity(Long idCliente) {
        return clienteRepository.findById(idCliente)
                .orElseThrow(() -> ClienteNaoEncontradoException.porId(idCliente));
    }

    private String normalizarTextoOpcional(String valor) {
        if (valor == null) {
            return null;
        }

        String texto = valor.trim();
        return texto.isBlank() ? null : texto;
    }

    private void validarAtivoObrigatorio(Boolean ativo) {
        if (ativo == null) {
            throw new IllegalArgumentException("O campo ativo é obrigatório.");
        }
    }
}