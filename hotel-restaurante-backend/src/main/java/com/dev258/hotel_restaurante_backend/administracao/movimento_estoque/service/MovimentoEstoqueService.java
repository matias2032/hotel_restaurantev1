package com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.service;

import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.dto.MovimentoEstoqueRequestDTO;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.dto.MovimentoEstoqueResponseDTO;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.OrigemMovimentoEstoque;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoItemEstoque;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.entity.MovimentoEstoqueEntity.TipoMovimentoEstoque;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.exception.MovimentoEstoqueRegraNegocioException;
import com.dev258.hotel_restaurante_backend.administracao.movimento_estoque.repository.MovimentoEstoqueRepository;
import com.dev258.hotel_restaurante_backend.administracao.usuario.entity.UsuarioEntity;
import com.dev258.hotel_restaurante_backend.administracao.usuario.repository.UsuarioRepository;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.exception.IngredienteNaoEncontradoException;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository.IngredienteRepository;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.exception.ProdutoNaoEncontradoException;
import com.dev258.hotel_restaurante_backend.catalogo.produto.exception.ProdutoRegraNegocioException;
import com.dev258.hotel_restaurante_backend.catalogo.produto.repository.ProdutoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MovimentoEstoqueService {

    private final MovimentoEstoqueRepository movimentoEstoqueRepository;
    private final ProdutoRepository produtoRepository;
    private final IngredienteRepository ingredienteRepository;
    private final UsuarioRepository usuarioRepository;

    // ─────────────────────────────────────────────────────────────
    // LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<MovimentoEstoqueResponseDTO> listarMovimentos(
            TipoItemEstoque tipoItem,
            TipoMovimentoEstoque tipoMovimento,
            Long idProduto,
            Long idIngrediente,
            Long idUsuario,
            LocalDateTime inicio,
            LocalDateTime fim
    ) {
        List<MovimentoEstoqueEntity> movimentos;

        if (inicio != null && fim != null) {
            validarPeriodo(inicio, fim);

            movimentos = movimentoEstoqueRepository
                    .findByMovimentadoEmBetweenOrderByMovimentadoEmDescIdMovimentoEstoqueDesc(
                            inicio,
                            fim
                    );
        } else {
            movimentos = movimentoEstoqueRepository
                    .findAllByOrderByMovimentadoEmDescIdMovimentoEstoqueDesc();
        }

        return movimentos
                .stream()
                .filter(movimento -> tipoItem == null || movimento.getTipoItem() == tipoItem)
                .filter(movimento -> tipoMovimento == null || movimento.getTipoMovimento() == tipoMovimento)
                .filter(movimento -> idProduto == null || (
                        movimento.getProduto() != null
                                && movimento.getProduto().getIdProduto().equals(idProduto)
                ))
                .filter(movimento -> idIngrediente == null || (
                        movimento.getIngrediente() != null
                                && movimento.getIngrediente().getIdIngrediente().equals(idIngrediente)
                ))
                .filter(movimento -> idUsuario == null || (
                        movimento.getUsuario() != null
                                && movimento.getUsuario().getIdUsuario().equals(idUsuario)
                ))
                .map(MovimentoEstoqueResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // BUSCAR POR ID
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public MovimentoEstoqueResponseDTO buscarPorId(Long idMovimentoEstoque) {
        MovimentoEstoqueEntity movimento = buscarMovimentoObrigatorio(idMovimentoEstoque);

        return new MovimentoEstoqueResponseDTO(movimento);
    }

    // ─────────────────────────────────────────────────────────────
    // MOVIMENTAR ESTOQUE
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public MovimentoEstoqueResponseDTO movimentarEstoque(
            MovimentoEstoqueRequestDTO dto
    ) {
        validarRequest(dto);

        UsuarioEntity usuario = buscarUsuarioObrigatorio(dto.idUsuario());

        return switch (dto.tipoItem()) {
            case PRODUTO -> movimentarProduto(dto, usuario);
            case INGREDIENTE -> movimentarIngrediente(dto, usuario);
        };
    }

    // ─────────────────────────────────────────────────────────────
    // MOVIMENTAÇÃO — PRODUTO
    // ─────────────────────────────────────────────────────────────

    private MovimentoEstoqueResponseDTO movimentarProduto(
            MovimentoEstoqueRequestDTO dto,
            UsuarioEntity usuario
    ) {
        validarReferenciaProduto(dto);

        ProdutoEntity produto = buscarProdutoObrigatorio(dto.idProduto());

        if (!Boolean.TRUE.equals(produto.getControlaEstoque())) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "Este produto não controla estoque próprio. Para produtos controlados por receita, movimente os ingredientes."
            );
        }

        BigDecimal quantidadeAnterior = normalizarQuantidadeAtual(
                produto.getQuantidadeEstoque()
        );

        ResultadoMovimento resultado = calcularResultadoMovimento(
                dto.tipoMovimento(),
                quantidadeAnterior,
                dto.quantidadeMovimentada()
        );

        produto.setQuantidadeEstoque(resultado.quantidadePosterior());
        produtoRepository.save(produto);

        MovimentoEstoqueEntity movimento = MovimentoEstoqueEntity.builder()
                .tipoItem(TipoItemEstoque.PRODUTO)
                .produto(produto)
                .ingrediente(null)
                .tipoMovimento(dto.tipoMovimento())
                .motivo(limparObrigatorio(dto.motivo(), "O motivo do movimento é obrigatório."))
                .observacoes(limparOpcional(dto.observacoes()))
                .quantidadeMovimentada(resultado.quantidadeMovimentadaReal())
                .quantidadeAnterior(quantidadeAnterior)
                .quantidadePosterior(resultado.quantidadePosterior())
                .usuario(usuario)
                .origem(OrigemMovimentoEstoque.MANUAL)
                .movimentadoEm(LocalDateTime.now())
                .build();

        MovimentoEstoqueEntity movimentoSalvo =
                movimentoEstoqueRepository.save(movimento);

        return new MovimentoEstoqueResponseDTO(movimentoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // MOVIMENTAÇÃO — INGREDIENTE
    // ─────────────────────────────────────────────────────────────

    private MovimentoEstoqueResponseDTO movimentarIngrediente(
            MovimentoEstoqueRequestDTO dto,
            UsuarioEntity usuario
    ) {
        validarReferenciaIngrediente(dto);

        IngredienteEntity ingrediente = buscarIngredienteObrigatorio(
                dto.idIngrediente()
        );

        if (!Boolean.TRUE.equals(ingrediente.getControlaEstoque())) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "Este ingrediente não controla estoque."
            );
        }

        BigDecimal quantidadeAnterior = normalizarQuantidadeAtual(
                ingrediente.getQuantidadeEstoque()
        );

        ResultadoMovimento resultado = calcularResultadoMovimento(
                dto.tipoMovimento(),
                quantidadeAnterior,
                dto.quantidadeMovimentada()
        );

        ingrediente.setQuantidadeEstoque(resultado.quantidadePosterior());
        ingredienteRepository.save(ingrediente);

        MovimentoEstoqueEntity movimento = MovimentoEstoqueEntity.builder()
                .tipoItem(TipoItemEstoque.INGREDIENTE)
                .produto(null)
                .ingrediente(ingrediente)
                .tipoMovimento(dto.tipoMovimento())
                .motivo(limparObrigatorio(dto.motivo(), "O motivo do movimento é obrigatório."))
                .observacoes(limparOpcional(dto.observacoes()))
                .quantidadeMovimentada(resultado.quantidadeMovimentadaReal())
                .quantidadeAnterior(quantidadeAnterior)
                .quantidadePosterior(resultado.quantidadePosterior())
                .usuario(usuario)
                .origem(OrigemMovimentoEstoque.MANUAL)
                .movimentadoEm(LocalDateTime.now())
                .build();

        MovimentoEstoqueEntity movimentoSalvo =
                movimentoEstoqueRepository.save(movimento);

        return new MovimentoEstoqueResponseDTO(movimentoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // CÁLCULO DO MOVIMENTO
    // ─────────────────────────────────────────────────────────────

    private ResultadoMovimento calcularResultadoMovimento(
            TipoMovimentoEstoque tipoMovimento,
            BigDecimal quantidadeAnterior,
            BigDecimal quantidadeInformada
    ) {
        BigDecimal quantidade = normalizarQuantidadeMovimentada(
                quantidadeInformada
        );

        BigDecimal quantidadePosterior;

        switch (tipoMovimento) {
            case ENTRADA -> quantidadePosterior = quantidadeAnterior.add(quantidade);

            case SAIDA, PERDA, VENCIMENTO -> {
                quantidadePosterior = quantidadeAnterior.subtract(quantidade);

                if (quantidadePosterior.compareTo(BigDecimal.ZERO) < 0) {
                    throw new MovimentoEstoqueRegraNegocioException(
                            "A movimentação não pode deixar o estoque negativo."
                    );
                }
            }

            case AJUSTE, CORRECAO, INVENTARIO -> {
                quantidadePosterior = quantidade;

                if (quantidadePosterior.compareTo(quantidadeAnterior) == 0) {
                    throw new MovimentoEstoqueRegraNegocioException(
                            "A quantidade final informada é igual à quantidade actual."
                    );
                }

                quantidade = quantidadePosterior
                        .subtract(quantidadeAnterior)
                        .abs();
            }

            default -> throw new MovimentoEstoqueRegraNegocioException(
                    "Tipo de movimento de estoque inválido."
            );
        }

        return new ResultadoMovimento(
                quantidade,
                quantidadePosterior.setScale(3, RoundingMode.HALF_UP)
        );
    }

    private record ResultadoMovimento(
            BigDecimal quantidadeMovimentadaReal,
            BigDecimal quantidadePosterior
    ) {
    }

    // ─────────────────────────────────────────────────────────────
    // BUSCAS OBRIGATÓRIAS
    // ─────────────────────────────────────────────────────────────

    private MovimentoEstoqueEntity buscarMovimentoObrigatorio(
            Long idMovimentoEstoque
    ) {
        if (idMovimentoEstoque == null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "ID do movimento de estoque não informado."
            );
        }

        return movimentoEstoqueRepository
                .findById(idMovimentoEstoque)
                .orElseThrow(() -> new MovimentoEstoqueRegraNegocioException(
                        "Movimento de estoque não encontrado."
                ));
    }

    private ProdutoEntity buscarProdutoObrigatorio(Long idProduto) {
        if (idProduto == null) {
            throw new ProdutoNaoEncontradoException(
                    "ID do produto não informado."
            );
        }

        return produtoRepository
                .findById(idProduto)
                .orElseThrow(() -> new ProdutoNaoEncontradoException(idProduto));
    }

    private IngredienteEntity buscarIngredienteObrigatorio(Long idIngrediente) {
        if (idIngrediente == null) {
            throw new IngredienteNaoEncontradoException(
                    "ID do ingrediente não informado."
            );
        }

        return ingredienteRepository
                .findById(idIngrediente)
                .orElseThrow(() -> new IngredienteNaoEncontradoException(idIngrediente));
    }

    private UsuarioEntity buscarUsuarioObrigatorio(Long idUsuario) {
        if (idUsuario == null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "ID do usuário responsável não informado."
            );
        }

        return usuarioRepository
                .findById(idUsuario)
                .orElseThrow(() -> new MovimentoEstoqueRegraNegocioException(
                        "Usuário responsável não encontrado."
                ));
    }

    // ─────────────────────────────────────────────────────────────
    // VALIDAÇÕES
    // ─────────────────────────────────────────────────────────────

    private void validarRequest(MovimentoEstoqueRequestDTO dto) {
        if (dto == null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "Dados do movimento de estoque não informados."
            );
        }

        if (dto.tipoItem() == null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "O tipo do item é obrigatório."
            );
        }

        if (dto.tipoMovimento() == null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "O tipo do movimento é obrigatório."
            );
        }

        limparObrigatorio(
                dto.motivo(),
                "O motivo do movimento é obrigatório."
        );

        normalizarQuantidadeMovimentada(
                dto.quantidadeMovimentada()
        );
    }

    private void validarReferenciaProduto(MovimentoEstoqueRequestDTO dto) {
        if (dto.idProduto() == null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "ID do produto é obrigatório para movimento de produto."
            );
        }

        if (dto.idIngrediente() != null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "Movimento de produto não deve informar ID de ingrediente."
            );
        }
    }

    private void validarReferenciaIngrediente(MovimentoEstoqueRequestDTO dto) {
        if (dto.idIngrediente() == null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "ID do ingrediente é obrigatório para movimento de ingrediente."
            );
        }

        if (dto.idProduto() != null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "Movimento de ingrediente não deve informar ID de produto."
            );
        }
    }

    private void validarPeriodo(
            LocalDateTime inicio,
            LocalDateTime fim
    ) {
        if (inicio.isAfter(fim)) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "A data inicial não pode ser posterior à data final."
            );
        }
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS
    // ─────────────────────────────────────────────────────────────

    private BigDecimal normalizarQuantidadeAtual(BigDecimal quantidade) {
        BigDecimal valor = quantidade != null
                ? quantidade
                : BigDecimal.ZERO;

        if (valor.compareTo(BigDecimal.ZERO) < 0) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "A quantidade actual do estoque não pode ser negativa."
            );
        }

        return valor.setScale(3, RoundingMode.HALF_UP);
    }

    private BigDecimal normalizarQuantidadeMovimentada(BigDecimal quantidade) {
        if (quantidade == null) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "A quantidade movimentada é obrigatória."
            );
        }

        if (quantidade.compareTo(BigDecimal.ZERO) <= 0) {
            throw new MovimentoEstoqueRegraNegocioException(
                    "A quantidade movimentada deve ser maior que zero."
            );
        }

        return quantidade.setScale(3, RoundingMode.HALF_UP);
    }

    private String limparObrigatorio(
            String valor,
            String mensagemErro
    ) {
        String valorLimpo = limparOpcional(valor);

        if (valorLimpo == null) {
            throw new MovimentoEstoqueRegraNegocioException(mensagemErro);
        }

        return valorLimpo;
    }

    private String limparOpcional(String valor) {
        if (valor == null) {
            return null;
        }

        String valorLimpo = valor.trim();

        return valorLimpo.isEmpty() ? null : valorLimpo;
    }
}