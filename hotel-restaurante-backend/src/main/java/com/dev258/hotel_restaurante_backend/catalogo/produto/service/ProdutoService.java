package com.dev258.hotel_restaurante_backend.catalogo.produto.service;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.exception.IngredienteNaoEncontradoException;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository.IngredienteRepository;
import com.dev258.hotel_restaurante_backend.catalogo.produto.dto.CategoriaProdutoRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.produto.dto.CategoriaProdutoResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.produto.dto.ProdutoRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.produto.dto.ProdutoResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.CategoriaProdutoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoImagemEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoIngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoIngredienteId;
import com.dev258.hotel_restaurante_backend.catalogo.produto.exception.CategoriaProdutoNaoEncontradaException;
import com.dev258.hotel_restaurante_backend.catalogo.produto.exception.ProdutoNaoEncontradoException;
import com.dev258.hotel_restaurante_backend.catalogo.produto.exception.ProdutoRegraNegocioException;
import com.dev258.hotel_restaurante_backend.catalogo.produto.repository.CategoriaProdutoRepository;
import com.dev258.hotel_restaurante_backend.catalogo.produto.repository.ProdutoImagemRepository;
import com.dev258.hotel_restaurante_backend.catalogo.produto.repository.ProdutoIngredienteRepository;
import com.dev258.hotel_restaurante_backend.catalogo.produto.repository.ProdutoRepository;
import com.dev258.hotel_restaurante_backend.catalogo.produto.entity.ProdutoCategoriaEntity;
import com.dev258.hotel_restaurante_backend.catalogo.produto.repository.ProdutoCategoriaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class ProdutoService {

    private final CategoriaProdutoRepository categoriaProdutoRepository;
    private final ProdutoRepository produtoRepository;
    private final ProdutoImagemRepository produtoImagemRepository;
    private final ProdutoIngredienteRepository produtoIngredienteRepository;
    private final IngredienteRepository ingredienteRepository;
    private final ProdutoCategoriaRepository produtoCategoriaRepository;

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<CategoriaProdutoResponseDTO> listarCategorias(Boolean somenteAtivas) {
        List<CategoriaProdutoEntity> categorias = Boolean.TRUE.equals(somenteAtivas)
                ? categoriaProdutoRepository.findByAtivoTrueOrderByOrdemAscNomeAsc()
                : categoriaProdutoRepository.findAllByOrderByOrdemAscNomeAsc();

        return categorias
                .stream()
                .map(CategoriaProdutoResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — BUSCAR POR ID
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public CategoriaProdutoResponseDTO buscarCategoriaPorId(Long idCategoriaProduto) {
        CategoriaProdutoEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaProduto);
        return new CategoriaProdutoResponseDTO(categoria);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — CRIAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public CategoriaProdutoResponseDTO criarCategoria(CategoriaProdutoRequestDTO dto) {
        validarNomeCategoriaDuplicado(dto.nome(), null);

        CategoriaProdutoEntity categoria = CategoriaProdutoEntity.builder()
                .nome(limparObrigatorio(dto.nome(), "O nome da categoria é obrigatório."))
                .descricao(limparOpcional(dto.descricao()))
                .ordem(dto.ordem() != null ? dto.ordem() : 0)
                .ativo(dto.ativo() != null ? dto.ativo() : true)
                .build();

        CategoriaProdutoEntity categoriaSalva = categoriaProdutoRepository.save(categoria);

        return new CategoriaProdutoResponseDTO(categoriaSalva);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — EDITAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public CategoriaProdutoResponseDTO editarCategoria(
            Long idCategoriaProduto,
            CategoriaProdutoRequestDTO dto
    ) {
        CategoriaProdutoEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaProduto);

        validarNomeCategoriaDuplicado(dto.nome(), idCategoriaProduto);

        categoria.setNome(limparObrigatorio(dto.nome(), "O nome da categoria é obrigatório."));
        categoria.setDescricao(limparOpcional(dto.descricao()));
        categoria.setOrdem(dto.ordem() != null ? dto.ordem() : 0);
        categoria.setAtivo(dto.ativo() != null ? dto.ativo() : true);

        CategoriaProdutoEntity categoriaSalva = categoriaProdutoRepository.save(categoria);

        return new CategoriaProdutoResponseDTO(categoriaSalva);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — ALTERAR ESTADO
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public CategoriaProdutoResponseDTO alterarEstadoCategoria(
            Long idCategoriaProduto,
            Boolean ativo
    ) {
        CategoriaProdutoEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaProduto);

        boolean vaiDesativar = Boolean.FALSE.equals(ativo);

if (vaiDesativar) {
    validarCategoriaSemProdutosAtivos(idCategoriaProduto);
}

        categoria.setAtivo(ativo != null ? ativo : true);

        CategoriaProdutoEntity categoriaSalva = categoriaProdutoRepository.save(categoria);

        return new CategoriaProdutoResponseDTO(categoriaSalva);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — REMOVER LÓGICO
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public void desativarCategoria(Long idCategoriaProduto) {
        CategoriaProdutoEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaProduto);

validarCategoriaSemProdutosAtivos(idCategoriaProduto);

        categoria.setAtivo(false);
        categoriaProdutoRepository.save(categoria);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<ProdutoResponseDTO> listarProdutos(
            Boolean somenteAtivos,
            Boolean somenteDisponiveis,
            Boolean somenteDestaques,
            Long idCategoriaProduto
    ) {
        List<ProdutoEntity> produtos;

if (idCategoriaProduto != null && Boolean.TRUE.equals(somenteDisponiveis)) {
    produtos = produtoRepository
            .findDistinctByCategorias_CategoriaProduto_IdCategoriaProdutoAndDisponivelTrueAndAtivoTrueOrderByNomeAsc(
                    idCategoriaProduto
            );
} else if (idCategoriaProduto != null) {
    produtos = Boolean.TRUE.equals(somenteAtivos)
            ? produtoRepository
            .findDistinctByCategorias_CategoriaProduto_IdCategoriaProdutoAndAtivoTrueOrderByNomeAsc(
                    idCategoriaProduto
            )
            : produtoRepository
            .findDistinctByCategorias_CategoriaProduto_IdCategoriaProdutoOrderByNomeAsc(
                    idCategoriaProduto
            );
} else if (Boolean.TRUE.equals(somenteDestaques)) {
            produtos = produtoRepository.findByDestaqueTrueAndAtivoTrueOrderByNomeAsc();
        } else if (Boolean.TRUE.equals(somenteDisponiveis)) {
            produtos = produtoRepository.findByDisponivelTrueAndAtivoTrueOrderByNomeAsc();
        } else if (Boolean.TRUE.equals(somenteAtivos)) {
            produtos = produtoRepository.findByAtivoTrueOrderByNomeAsc();
        } else {
            produtos = produtoRepository.findAllByOrderByNomeAsc();
        }

        if (Boolean.TRUE.equals(somenteDestaques) && idCategoriaProduto != null) {
            produtos = produtos
                    .stream()
                    .filter(produto -> Boolean.TRUE.equals(produto.getDestaque()))
                    .toList();
        }

        return produtos
                .stream()
                .map(ProdutoResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — BUSCAR POR ID
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public ProdutoResponseDTO buscarProdutoPorId(Long idProduto) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);
        return new ProdutoResponseDTO(produto);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — CRIAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO criarProduto(ProdutoRequestDTO dto) {
        validarNomeProdutoDuplicado(dto.nome(), null);



        ProdutoEntity produto = ProdutoEntity.builder()
                
                .nome(limparObrigatorio(dto.nome(), "O nome do produto é obrigatório."))
                .descricao(limparOpcional(dto.descricao()))
                .preco(resolverPreco(dto.preco()))
                .imagemPrincipalUrl(limparOpcional(dto.imagemPrincipalUrl()))
                .controlaEstoque(dto.controlaEstoque() != null ? dto.controlaEstoque() : false)
                .quantidadeEstoque(resolverQuantidadeEstoque(
                        dto.controlaEstoque(),
                        dto.quantidadeEstoque()
                ))
                .tempoPreparoMinutos(resolverTempoPreparo(dto.tempoPreparoMinutos()))
                .disponivel(dto.disponivel() != null ? dto.disponivel() : true)
                .destaque(dto.destaque() != null ? dto.destaque() : false)
                .ativo(dto.ativo() != null ? dto.ativo() : true)
                .build();

                aplicarCategoriasNoProduto(produto,dto.idCategoriasProduto(),false);

        aplicarImagensNoProduto(produto, dto.imagens());
        aplicarIngredientesNoProduto(produto, dto.ingredientes());

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — EDITAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO editarProduto(
            Long idProduto,
            ProdutoRequestDTO dto
    ) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        validarNomeProdutoDuplicado(dto.nome(), idProduto);


        produto.setNome(limparObrigatorio(dto.nome(), "O nome do produto é obrigatório."));
        produto.setDescricao(limparOpcional(dto.descricao()));
        produto.setPreco(resolverPreco(dto.preco()));
        produto.setImagemPrincipalUrl(limparOpcional(dto.imagemPrincipalUrl()));

        Boolean controlaEstoque = dto.controlaEstoque() != null ? dto.controlaEstoque() : false;
        produto.setControlaEstoque(controlaEstoque);
        produto.setQuantidadeEstoque(
                resolverQuantidadeEstoque(controlaEstoque, dto.quantidadeEstoque())
        );

        produto.setTempoPreparoMinutos(resolverTempoPreparo(dto.tempoPreparoMinutos()));
        produto.setDisponivel(dto.disponivel() != null ? dto.disponivel() : true);
        produto.setDestaque(dto.destaque() != null ? dto.destaque() : false);
        produto.setAtivo(dto.ativo() != null ? dto.ativo() : true);



        /*
 * Regra:
 * - dto.idCategoriasProduto() == null -> mantém categorias atuais.
 * - dto.idCategoriasProduto() == []   -> remove todas as categorias.
 * - dto.idCategoriasProduto() com IDs -> substitui pelas categorias enviadas.
 */
if (dto.idCategoriasProduto() != null) {
    aplicarCategoriasNoProduto(
            produto,
            dto.idCategoriasProduto(),
            true
    );
}

        /*
         * Regra:
         * - dto.imagens() == null       -> mantém imagens atuais.
         * - dto.imagens() == []         -> remove todas as imagens.
         * - dto.imagens() com itens     -> substitui pelas imagens enviadas.
         */
        if (dto.imagens() != null) {
            produto.getImagens().clear();
            aplicarImagensNoProduto(produto, dto.imagens());
        }

        /*
         * Regra:
         * - dto.ingredientes() == null  -> mantém ingredientes atuais.
         * - dto.ingredientes() == []    -> remove todos os ingredientes.
         * - dto.ingredientes() com itens -> substitui pelos enviados.
         */
        if (dto.ingredientes() != null) {
            produto.getIngredientes().clear();
            aplicarIngredientesNoProduto(produto, dto.ingredientes());
        }

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — DISPONIBILIDADE
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO alterarDisponibilidadeProduto(
            Long idProduto,
            Boolean disponivel
    ) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        if (Boolean.FALSE.equals(produto.getAtivo()) && Boolean.TRUE.equals(disponivel)) {
            throw new ProdutoRegraNegocioException(
                    "Não é possível disponibilizar um produto inativo."
            );
        }

        produto.setDisponivel(disponivel != null ? disponivel : true);

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — DESTAQUE
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO alterarDestaqueProduto(
            Long idProduto,
            Boolean destaque
    ) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        produto.setDestaque(destaque != null ? destaque : false);

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — ACTIVAR / DESACTIVAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO alterarEstadoProduto(
            Long idProduto,
            Boolean ativo
    ) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        produto.setAtivo(ativo != null ? ativo : true);

        if (Boolean.FALSE.equals(produto.getAtivo())) {
            produto.setDisponivel(false);
            produto.setDestaque(false);
        }

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // PRODUTOS — REMOVER LÓGICO
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public void desativarProduto(Long idProduto) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        produto.setAtivo(false);
        produto.setDisponivel(false);
        produto.setDestaque(false);

        produtoRepository.save(produto);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<ProdutoResponseDTO.ProdutoImagemResponseDTO> listarImagensDoProduto(
            Long idProduto
    ) {
        buscarProdutoEntityObrigatorio(idProduto);

        return produtoImagemRepository
                .findByProduto_IdProdutoOrderByPrincipalDescOrdemAscIdProdutoImagemAsc(idProduto)
                .stream()
                .map(ProdutoResponseDTO.ProdutoImagemResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — ADICIONAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO adicionarImagemAoProduto(
            Long idProduto,
            ProdutoRequestDTO.ProdutoImagemRequestDTO dto
    ) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        String imagemUrl = limparObrigatorio(dto.imagemUrl(), "A URL da imagem é obrigatória.");

        ProdutoImagemEntity imagem = ProdutoImagemEntity.builder()
                .produto(produto)
                .imagemUrl(imagemUrl)
                .legenda(limparOpcional(dto.legenda()))
                .principal(dto.principal() != null ? dto.principal() : false)
                .ordem(dto.ordem() != null ? dto.ordem() : 0)
                .build();

        if (Boolean.TRUE.equals(imagem.getPrincipal())) {
            produto.getImagens()
                    .forEach(img -> img.setPrincipal(false));
        } else if (produto.getImagens().isEmpty()) {
            imagem.setPrincipal(true);
        }

        produto.adicionarImagem(imagem);

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — DEFINIR PRINCIPAL
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO definirImagemPrincipal(
            Long idProduto,
            Long idProdutoImagem
    ) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        ProdutoImagemEntity imagemPrincipal = produto.getImagens()
                .stream()
                .filter(imagem -> imagem.getIdProdutoImagem().equals(idProdutoImagem))
                .findFirst()
                .orElseThrow(() -> new ProdutoRegraNegocioException(
                        "Imagem não encontrada para este produto."
                ));

        produto.getImagens()
                .forEach(imagem -> imagem.setPrincipal(false));

        imagemPrincipal.setPrincipal(true);
        produto.setImagemPrincipalUrl(imagemPrincipal.getImagemUrl());

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — REMOVER
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO removerImagemDoProduto(
            Long idProduto,
            Long idProdutoImagem
    ) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        ProdutoImagemEntity imagemParaRemover = produto.getImagens()
                .stream()
                .filter(imagem -> imagem.getIdProdutoImagem().equals(idProdutoImagem))
                .findFirst()
                .orElseThrow(() -> new ProdutoRegraNegocioException(
                        "Imagem não encontrada para este produto."
                ));

        boolean imagemEraPrincipal = Boolean.TRUE.equals(imagemParaRemover.getPrincipal());

        produto.removerImagem(imagemParaRemover);

        if (imagemEraPrincipal && !produto.getImagens().isEmpty()) {
            produto.getImagens()
                    .stream()
                    .min(Comparator.comparing(ProdutoImagemEntity::getOrdem)
                            .thenComparing(ProdutoImagemEntity::getIdProdutoImagem))
                    .ifPresent(imagem -> {
                        imagem.setPrincipal(true);
                        produto.setImagemPrincipalUrl(imagem.getImagemUrl());
                    });
        }

        if (produto.getImagens().isEmpty()) {
            produto.setImagemPrincipalUrl(null);
        }

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES DO PRODUTO — LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<ProdutoResponseDTO.ProdutoIngredienteResponseDTO> listarIngredientesDoProduto(
            Long idProduto
    ) {
        buscarProdutoEntityObrigatorio(idProduto);

        return produtoIngredienteRepository
                .findByProduto_IdProdutoOrderByIngrediente_NomeAsc(idProduto)
                .stream()
                .map(ProdutoResponseDTO.ProdutoIngredienteResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES DO PRODUTO — ADICIONAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO adicionarIngredienteAoProduto(
            Long idProduto,
            ProdutoRequestDTO.ProdutoIngredienteRequestDTO dto
    ) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        ProdutoIngredienteEntity produtoIngrediente = criarProdutoIngredienteEntity(produto, dto);

        boolean jaExiste = produto.getIngredientes()
                .stream()
                .anyMatch(item -> item.getIngrediente()
                        .getIdIngrediente()
                        .equals(produtoIngrediente.getIngrediente().getIdIngrediente()));

        if (jaExiste) {
            throw new ProdutoRegraNegocioException(
                    "Este ingrediente já está associado ao produto."
            );
        }

        produto.adicionarIngrediente(produtoIngrediente);

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES DO PRODUTO — REMOVER
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ProdutoResponseDTO removerIngredienteDoProduto(
            Long idProduto,
            Long idIngrediente
    ) {
        ProdutoEntity produto = buscarProdutoEntityObrigatorio(idProduto);

        ProdutoIngredienteEntity ingredienteParaRemover = produto.getIngredientes()
                .stream()
                .filter(item -> item.getIngrediente().getIdIngrediente().equals(idIngrediente))
                .findFirst()
                .orElseThrow(() -> new ProdutoRegraNegocioException(
                        "Ingrediente não encontrado neste produto."
                ));

        produto.removerIngrediente(ingredienteParaRemover);

        ProdutoEntity produtoSalvo = produtoRepository.save(produto);

        return new ProdutoResponseDTO(produtoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS — BUSCAS
    // ─────────────────────────────────────────────────────────────

    private CategoriaProdutoEntity buscarCategoriaEntityObrigatoria(Long idCategoriaProduto) {
        if (idCategoriaProduto == null) {
            throw new CategoriaProdutoNaoEncontradaException(
                    "ID da categoria de produto não informado."
            );
        }

        return categoriaProdutoRepository.findById(idCategoriaProduto)
                .orElseThrow(() -> new CategoriaProdutoNaoEncontradaException(idCategoriaProduto));
    }
private void validarCategoriaSemProdutosAtivos(Long idCategoriaProduto) {
    boolean existeProdutoAtivo =
            produtoCategoriaRepository
                    .existsByCategoriaProduto_IdCategoriaProdutoAndProduto_AtivoTrue(
                            idCategoriaProduto
                    );

    if (existeProdutoAtivo) {
        throw new ProdutoRegraNegocioException(
                "Não é possível desativar esta categoria porque existem produtos ativos associados."
        );
    }
}
    private ProdutoEntity buscarProdutoEntityObrigatorio(Long idProduto) {
        if (idProduto == null) {
            throw new ProdutoNaoEncontradoException(
                    "ID do produto não informado."
            );
        }

        return produtoRepository.findById(idProduto)
                .orElseThrow(() -> new ProdutoNaoEncontradoException(idProduto));
    }

    private IngredienteEntity buscarIngredienteEntityObrigatorio(Long idIngrediente) {
        if (idIngrediente == null) {
            throw new IngredienteNaoEncontradoException(
                    "ID do ingrediente não informado."
            );
        }

        return ingredienteRepository.findById(idIngrediente)
                .orElseThrow(() -> new IngredienteNaoEncontradoException(idIngrediente));
    }


    // ─────────────────────────────────────────────────────────────
    // HELPERS — VALIDAÇÕES
    // ─────────────────────────────────────────────────────────────

    private void validarNomeCategoriaDuplicado(String nome, Long idCategoriaIgnorada) {
        String nomeLimpo = limparObrigatorio(nome, "O nome da categoria é obrigatório.");

        boolean existe;

        if (idCategoriaIgnorada == null) {
            existe = categoriaProdutoRepository.existsByNomeIgnoreCase(nomeLimpo);
        } else {
            existe = categoriaProdutoRepository
                    .existsByNomeIgnoreCaseAndIdCategoriaProdutoNot(
                            nomeLimpo,
                            idCategoriaIgnorada
                    );
        }

        if (existe) {
            throw new ProdutoRegraNegocioException(
                    "Já existe uma categoria de produto com este nome."
            );
        }
    }

    private void validarNomeProdutoDuplicado(String nome, Long idProdutoIgnorado) {
        String nomeLimpo = limparObrigatorio(nome, "O nome do produto é obrigatório.");

        boolean existe;

        if (idProdutoIgnorado == null) {
            existe = produtoRepository.existsByNomeIgnoreCase(nomeLimpo);
        } else {
            existe = produtoRepository.existsByNomeIgnoreCaseAndIdProdutoNot(
                    nomeLimpo,
                    idProdutoIgnorado
            );
        }

        if (existe) {
            throw new ProdutoRegraNegocioException(
                    "Já existe um produto com este nome."
            );
        }
    }

    private BigDecimal resolverPreco(BigDecimal preco) {
        BigDecimal valor = preco != null ? preco : BigDecimal.ZERO;

        if (valor.compareTo(BigDecimal.ZERO) < 0) {
            throw new ProdutoRegraNegocioException(
                    "O preço do produto não pode ser negativo."
            );
        }

        return valor;
    }

    private BigDecimal resolverQuantidadeEstoque(
            Boolean controlaEstoque,
            BigDecimal quantidadeEstoque
    ) {
        if (!Boolean.TRUE.equals(controlaEstoque)) {
            return null;
        }

        BigDecimal quantidade = quantidadeEstoque != null
                ? quantidadeEstoque
                : BigDecimal.ZERO;

        if (quantidade.compareTo(BigDecimal.ZERO) < 0) {
            throw new ProdutoRegraNegocioException(
                    "A quantidade em estoque não pode ser negativa."
            );
        }

        return quantidade;
    }

    private Integer resolverTempoPreparo(Integer tempoPreparoMinutos) {
        if (tempoPreparoMinutos == null) {
            return null;
        }

        if (tempoPreparoMinutos < 0) {
            throw new ProdutoRegraNegocioException(
                    "O tempo de preparo não pode ser negativo."
            );
        }

        return tempoPreparoMinutos;
    }


    // ─────────────────────────────────────────────────────────────
// HELPERS — CATEGORIAS DO PRODUTO
// ─────────────────────────────────────────────────────────────

private void aplicarCategoriasNoProduto(
        ProdutoEntity produto,
        List<Long> idCategoriasProduto,
        boolean substituirCategoriasAtuais
) {
    if (substituirCategoriasAtuais) {
        produto.limparCategorias();
    }

    if (idCategoriasProduto == null || idCategoriasProduto.isEmpty()) {
        return;
    }

    Set<Long> idsUnicos = new LinkedHashSet<>(idCategoriasProduto);

    if (idsUnicos.size() != idCategoriasProduto.size()) {
        throw new ProdutoRegraNegocioException(
                "Não é permitido associar a mesma categoria mais de uma vez."
        );
    }

    int ordem = 0;

    for (Long idCategoriaProduto : idsUnicos) {
        CategoriaProdutoEntity categoria =
                buscarCategoriaEntityObrigatoria(idCategoriaProduto);

        if (Boolean.FALSE.equals(categoria.getAtivo())) {
            throw new ProdutoRegraNegocioException(
                    "Não é possível associar uma categoria de produto inativa."
            );
        }

        ProdutoCategoriaEntity produtoCategoria =
                ProdutoCategoriaEntity.builder()
                        .produto(produto)
                        .categoriaProduto(categoria)
                        .principal(ordem == 0)
                        .ordem(ordem)
                        .build();

        produto.adicionarCategoria(produtoCategoria);

        ordem++;
    }
}

    // ─────────────────────────────────────────────────────────────
    // HELPERS — IMAGENS
    // ─────────────────────────────────────────────────────────────

    private void aplicarImagensNoProduto(
            ProdutoEntity produto,
            List<ProdutoRequestDTO.ProdutoImagemRequestDTO> imagensDto
    ) {
        if (imagensDto == null || imagensDto.isEmpty()) {
            return;
        }

        int indicePrincipal = resolverIndiceImagemPrincipal(imagensDto);

        for (int i = 0; i < imagensDto.size(); i++) {
            ProdutoRequestDTO.ProdutoImagemRequestDTO imagemDto = imagensDto.get(i);

            String imagemUrl = limparObrigatorio(
                    imagemDto.imagemUrl(),
                    "A URL da imagem é obrigatória quando uma imagem é enviada."
            );

            boolean principal = i == indicePrincipal;

            ProdutoImagemEntity imagem = ProdutoImagemEntity.builder()
                    .produto(produto)
                    .imagemUrl(imagemUrl)
                    .legenda(limparOpcional(imagemDto.legenda()))
                    .principal(principal)
                    .ordem(imagemDto.ordem() != null ? imagemDto.ordem() : i)
                    .build();

            if (principal) {
                produto.setImagemPrincipalUrl(imagemUrl);
            }

            produto.adicionarImagem(imagem);
        }
    }

    private int resolverIndiceImagemPrincipal(
            List<ProdutoRequestDTO.ProdutoImagemRequestDTO> imagensDto
    ) {
        for (int i = 0; i < imagensDto.size(); i++) {
            if (Boolean.TRUE.equals(imagensDto.get(i).principal())) {
                return i;
            }
        }

        return 0;
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS — INGREDIENTES
    // ─────────────────────────────────────────────────────────────

    private void aplicarIngredientesNoProduto(
            ProdutoEntity produto,
            List<ProdutoRequestDTO.ProdutoIngredienteRequestDTO> ingredientesDto
    ) {
        if (ingredientesDto == null || ingredientesDto.isEmpty()) {
            return;
        }

        Set<Long> idsIngredientes = new HashSet<>();

        for (ProdutoRequestDTO.ProdutoIngredienteRequestDTO ingredienteDto : ingredientesDto) {
            if (ingredienteDto.idIngrediente() == null) {
                throw new ProdutoRegraNegocioException(
                        "ID do ingrediente é obrigatório quando um ingrediente é enviado."
                );
            }

            if (!idsIngredientes.add(ingredienteDto.idIngrediente())) {
                throw new ProdutoRegraNegocioException(
                        "Não é permitido repetir o mesmo ingrediente no produto."
                );
            }

            ProdutoIngredienteEntity produtoIngrediente =
                    criarProdutoIngredienteEntity(produto, ingredienteDto);

            produto.adicionarIngrediente(produtoIngrediente);
        }
    }

    private ProdutoIngredienteEntity criarProdutoIngredienteEntity(
            ProdutoEntity produto,
            ProdutoRequestDTO.ProdutoIngredienteRequestDTO dto
    ) {
        IngredienteEntity ingrediente = buscarIngredienteEntityObrigatorio(dto.idIngrediente());

        if (Boolean.FALSE.equals(ingrediente.getAtivo())) {
            throw new ProdutoRegraNegocioException(
                    "Não é possível associar um ingrediente inativo ao produto."
            );
        }

        BigDecimal quantidadePadrao = dto.quantidadePadrao() != null
                ? dto.quantidadePadrao()
                : BigDecimal.ONE;

        if (quantidadePadrao.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ProdutoRegraNegocioException(
                    "A quantidade padrão do ingrediente deve ser maior que zero."
            );
        }

        ProdutoIngredienteId id = null;

        if (produto.getIdProduto() != null) {
            id = ProdutoIngredienteId.builder()
                    .idProduto(produto.getIdProduto())
                    .idIngrediente(ingrediente.getIdIngrediente())
                    .build();
        }

        return ProdutoIngredienteEntity.builder()
                .id(id)
                .produto(produto)
                .ingrediente(ingrediente)
                .obrigatorio(dto.obrigatorio() != null ? dto.obrigatorio() : false)
                .removivel(dto.removivel() != null ? dto.removivel() : true)
                .permiteExtra(dto.permiteExtra() != null ? dto.permiteExtra() : true)
                .quantidadePadrao(quantidadePadrao)
                .build();
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS — TEXTO
    // ─────────────────────────────────────────────────────────────

    private String limparObrigatorio(String valor, String mensagemErro) {
        String valorLimpo = limparOpcional(valor);

        if (valorLimpo == null) {
            throw new ProdutoRegraNegocioException(mensagemErro);
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