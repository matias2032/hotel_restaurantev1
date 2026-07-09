package com.dev258.hotel_restaurante_backend.catalogo.ingrediente.service;

import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto.CategoriaIngredienteRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto.CategoriaIngredienteResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto.IngredienteRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.dto.IngredienteResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.CategoriaIngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteCategoriaEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.entity.IngredienteImagemEntity;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.exception.CategoriaIngredienteNaoEncontradaException;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.exception.IngredienteNaoEncontradoException;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.exception.IngredienteRegraNegocioException;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository.CategoriaIngredienteRepository;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository.IngredienteCategoriaRepository;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository.IngredienteImagemRepository;
import com.dev258.hotel_restaurante_backend.catalogo.ingrediente.repository.IngredienteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class IngredienteService {

    private final CategoriaIngredienteRepository categoriaIngredienteRepository;
    private final IngredienteRepository ingredienteRepository;
    private final IngredienteImagemRepository ingredienteImagemRepository;
    private final IngredienteCategoriaRepository ingredienteCategoriaRepository;

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<CategoriaIngredienteResponseDTO> listarCategorias(Boolean somenteAtivas) {
        List<CategoriaIngredienteEntity> categorias = Boolean.TRUE.equals(somenteAtivas)
                ? categoriaIngredienteRepository.findByAtivoTrueOrderByOrdemAscNomeAsc()
                : categoriaIngredienteRepository.findAllByOrderByOrdemAscNomeAsc();

        return categorias
                .stream()
                .map(CategoriaIngredienteResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — BUSCAR POR ID
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public CategoriaIngredienteResponseDTO buscarCategoriaPorId(Long idCategoriaIngrediente) {
        CategoriaIngredienteEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaIngrediente);
        return new CategoriaIngredienteResponseDTO(categoria);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — CRIAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public CategoriaIngredienteResponseDTO criarCategoria(CategoriaIngredienteRequestDTO dto) {
        validarNomeCategoriaDuplicado(dto.nome(), null);

        CategoriaIngredienteEntity categoria = CategoriaIngredienteEntity.builder()
                .nome(limparObrigatorio(dto.nome(), "O nome da categoria é obrigatório."))
                .descricao(limparOpcional(dto.descricao()))
                .ordem(dto.ordem() != null ? dto.ordem() : 0)
                .ativo(dto.ativo() != null ? dto.ativo() : true)
                .build();

        CategoriaIngredienteEntity categoriaSalva = categoriaIngredienteRepository.save(categoria);

        return new CategoriaIngredienteResponseDTO(categoriaSalva);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — EDITAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public CategoriaIngredienteResponseDTO editarCategoria(
            Long idCategoriaIngrediente,
            CategoriaIngredienteRequestDTO dto
    ) {
        CategoriaIngredienteEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaIngrediente);

        validarNomeCategoriaDuplicado(dto.nome(), idCategoriaIngrediente);

        categoria.setNome(limparObrigatorio(dto.nome(), "O nome da categoria é obrigatório."));
        categoria.setDescricao(limparOpcional(dto.descricao()));
        categoria.setOrdem(dto.ordem() != null ? dto.ordem() : 0);
        categoria.setAtivo(dto.ativo() != null ? dto.ativo() : true);

        CategoriaIngredienteEntity categoriaSalva = categoriaIngredienteRepository.save(categoria);

        return new CategoriaIngredienteResponseDTO(categoriaSalva);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — ACTIVAR / DESACTIVAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public CategoriaIngredienteResponseDTO alterarEstadoCategoria(
            Long idCategoriaIngrediente,
            Boolean ativo
    ) {
        CategoriaIngredienteEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaIngrediente);

        boolean vaiDesativar = Boolean.FALSE.equals(ativo);

        if (vaiDesativar) {
            validarCategoriaSemIngredientesAtivos(idCategoriaIngrediente);
        }

        categoria.setAtivo(ativo != null ? ativo : true);

        CategoriaIngredienteEntity categoriaSalva = categoriaIngredienteRepository.save(categoria);

        return new CategoriaIngredienteResponseDTO(categoriaSalva);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — REMOVER LÓGICO
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public void desativarCategoria(Long idCategoriaIngrediente) {
        CategoriaIngredienteEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaIngrediente);

        validarCategoriaSemIngredientesAtivos(idCategoriaIngrediente);

        categoria.setAtivo(false);
        categoriaIngredienteRepository.save(categoria);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<IngredienteResponseDTO> listarIngredientes(
            Boolean somenteAtivos,
            Boolean somenteDisponiveis,
            Long idCategoriaIngrediente
    ) {
        List<IngredienteEntity> ingredientes;

        if (idCategoriaIngrediente != null) {
            ingredientes = Boolean.TRUE.equals(somenteAtivos)
                    ? ingredienteRepository
                    .findDistinctByCategorias_CategoriaIngrediente_IdCategoriaIngredienteAndAtivoTrueOrderByNomeAsc(
                            idCategoriaIngrediente
                    )
                    : ingredienteRepository
                    .findDistinctByCategorias_CategoriaIngrediente_IdCategoriaIngredienteOrderByNomeAsc(
                            idCategoriaIngrediente
                    );
        } else if (Boolean.TRUE.equals(somenteDisponiveis)) {
            ingredientes = ingredienteRepository.findByDisponivelTrueAndAtivoTrueOrderByNomeAsc();
        } else if (Boolean.TRUE.equals(somenteAtivos)) {
            ingredientes = ingredienteRepository.findByAtivoTrueOrderByNomeAsc();
        } else {
            ingredientes = ingredienteRepository.findAllByOrderByNomeAsc();
        }

        if (Boolean.TRUE.equals(somenteDisponiveis) && idCategoriaIngrediente != null) {
            ingredientes = ingredientes
                    .stream()
                    .filter(ingrediente -> Boolean.TRUE.equals(ingrediente.getDisponivel()))
                    .filter(ingrediente -> Boolean.TRUE.equals(ingrediente.getAtivo()))
                    .toList();
        }

        return ingredientes
                .stream()
                .map(IngredienteResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — BUSCAR POR ID
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public IngredienteResponseDTO buscarIngredientePorId(Long idIngrediente) {
        IngredienteEntity ingrediente = buscarIngredienteEntityObrigatorio(idIngrediente);
        return new IngredienteResponseDTO(ingrediente);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — CRIAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public IngredienteResponseDTO criarIngrediente(IngredienteRequestDTO dto) {
        validarNomeIngredienteDuplicado(dto.nome(), null);

        IngredienteEntity ingrediente = IngredienteEntity.builder()
                .nome(limparObrigatorio(dto.nome(), "O nome do ingrediente é obrigatório."))
                .descricao(limparOpcional(dto.descricao()))
                .precoAdicional(resolverPrecoAdicional(dto.precoAdicional()))
                .controlaEstoque(dto.controlaEstoque() != null ? dto.controlaEstoque() : false)
                .quantidadeEstoque(resolverQuantidadeEstoque(
                        dto.controlaEstoque(),
                        dto.quantidadeEstoque()
                ))
                .disponivel(dto.disponivel() != null ? dto.disponivel() : true)
                .ativo(dto.ativo() != null ? dto.ativo() : true)
                .build();

        aplicarCategoriasNoIngrediente(
                ingrediente,
                dto.idCategoriasIngrediente(),
                false
        );

        aplicarImagensNoIngrediente(ingrediente, dto.imagens());

        IngredienteEntity ingredienteSalvo = ingredienteRepository.save(ingrediente);

        return new IngredienteResponseDTO(ingredienteSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — EDITAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public IngredienteResponseDTO editarIngrediente(
            Long idIngrediente,
            IngredienteRequestDTO dto
    ) {
        IngredienteEntity ingrediente = buscarIngredienteEntityObrigatorio(idIngrediente);

        validarNomeIngredienteDuplicado(dto.nome(), idIngrediente);

        ingrediente.setNome(limparObrigatorio(dto.nome(), "O nome do ingrediente é obrigatório."));
        ingrediente.setDescricao(limparOpcional(dto.descricao()));
        ingrediente.setPrecoAdicional(resolverPrecoAdicional(dto.precoAdicional()));

        Boolean controlaEstoque = dto.controlaEstoque() != null ? dto.controlaEstoque() : false;
        ingrediente.setControlaEstoque(controlaEstoque);
        ingrediente.setQuantidadeEstoque(
                resolverQuantidadeEstoque(controlaEstoque, dto.quantidadeEstoque())
        );

        ingrediente.setDisponivel(dto.disponivel() != null ? dto.disponivel() : true);
        ingrediente.setAtivo(dto.ativo() != null ? dto.ativo() : true);

        if (Boolean.FALSE.equals(ingrediente.getAtivo())) {
            ingrediente.setDisponivel(false);
        }

        /*
         * Regra:
         * - dto.idCategoriasIngrediente() == null  -> mantém categorias atuais.
         * - dto.idCategoriasIngrediente() == []    -> remove todas as categorias.
         * - dto.idCategoriasIngrediente() com IDs  -> substitui pelas categorias enviadas.
         */
        if (dto.idCategoriasIngrediente() != null) {
            aplicarCategoriasNoIngrediente(
                    ingrediente,
                    dto.idCategoriasIngrediente(),
                    true
            );
        }

        /*
         * Regra:
         * - dto.imagens() == null   -> mantém as imagens atuais.
         * - dto.imagens() == []     -> remove todas as imagens.
         * - dto.imagens() com itens -> substitui pelas imagens enviadas.
         */
        if (dto.imagens() != null) {
            ingrediente.getImagens().clear();
            aplicarImagensNoIngrediente(ingrediente, dto.imagens());
        }

        IngredienteEntity ingredienteSalvo = ingredienteRepository.save(ingrediente);

        return new IngredienteResponseDTO(ingredienteSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — DISPONIBILIDADE
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public IngredienteResponseDTO alterarDisponibilidadeIngrediente(
            Long idIngrediente,
            Boolean disponivel
    ) {
        IngredienteEntity ingrediente = buscarIngredienteEntityObrigatorio(idIngrediente);

        if (Boolean.FALSE.equals(ingrediente.getAtivo()) && Boolean.TRUE.equals(disponivel)) {
            throw new IngredienteRegraNegocioException(
                    "Não é possível disponibilizar um ingrediente inativo."
            );
        }

        ingrediente.setDisponivel(disponivel != null ? disponivel : true);

        IngredienteEntity ingredienteSalvo = ingredienteRepository.save(ingrediente);

        return new IngredienteResponseDTO(ingredienteSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — ACTIVAR / DESACTIVAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public IngredienteResponseDTO alterarEstadoIngrediente(
            Long idIngrediente,
            Boolean ativo
    ) {
        IngredienteEntity ingrediente = buscarIngredienteEntityObrigatorio(idIngrediente);

        ingrediente.setAtivo(ativo != null ? ativo : true);

        if (Boolean.FALSE.equals(ingrediente.getAtivo())) {
            ingrediente.setDisponivel(false);
        }

        IngredienteEntity ingredienteSalvo = ingredienteRepository.save(ingrediente);

        return new IngredienteResponseDTO(ingredienteSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // INGREDIENTES — REMOVER LÓGICO
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public void desativarIngrediente(Long idIngrediente) {
        IngredienteEntity ingrediente = buscarIngredienteEntityObrigatorio(idIngrediente);

        ingrediente.setAtivo(false);
        ingrediente.setDisponivel(false);

        ingredienteRepository.save(ingrediente);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<IngredienteResponseDTO.IngredienteImagemResponseDTO> listarImagensDoIngrediente(
            Long idIngrediente
    ) {
        buscarIngredienteEntityObrigatorio(idIngrediente);

        return ingredienteImagemRepository
                .findByIngrediente_IdIngredienteOrderByPrincipalDescOrdemAscIdIngredienteImagemAsc(
                        idIngrediente
                )
                .stream()
                .map(IngredienteResponseDTO.IngredienteImagemResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — ADICIONAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public IngredienteResponseDTO adicionarImagemAoIngrediente(
            Long idIngrediente,
            IngredienteRequestDTO.IngredienteImagemRequestDTO dto
    ) {
        IngredienteEntity ingrediente = buscarIngredienteEntityObrigatorio(idIngrediente);

        String imagemUrl = limparObrigatorio(dto.imagemUrl(), "A URL da imagem é obrigatória.");

        IngredienteImagemEntity imagem = IngredienteImagemEntity.builder()
                .ingrediente(ingrediente)
                .imagemUrl(imagemUrl)
                .legenda(limparOpcional(dto.legenda()))
                .principal(dto.principal() != null ? dto.principal() : false)
                .ordem(dto.ordem() != null ? dto.ordem() : 0)
                .build();

        if (Boolean.TRUE.equals(imagem.getPrincipal())) {
            ingrediente.getImagens()
                    .forEach(img -> img.setPrincipal(false));
        } else if (ingrediente.getImagens().isEmpty()) {
            imagem.setPrincipal(true);
        }

        ingrediente.adicionarImagem(imagem);

        IngredienteEntity ingredienteSalvo = ingredienteRepository.save(ingrediente);

        return new IngredienteResponseDTO(ingredienteSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — DEFINIR PRINCIPAL
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public IngredienteResponseDTO definirImagemPrincipal(
            Long idIngrediente,
            Long idIngredienteImagem
    ) {
        IngredienteEntity ingrediente = buscarIngredienteEntityObrigatorio(idIngrediente);

        IngredienteImagemEntity imagemPrincipal = ingrediente.getImagens()
                .stream()
                .filter(imagem -> imagem.getIdIngredienteImagem().equals(idIngredienteImagem))
                .findFirst()
                .orElseThrow(() -> new IngredienteRegraNegocioException(
                        "Imagem não encontrada para este ingrediente."
                ));

        ingrediente.getImagens()
                .forEach(imagem -> imagem.setPrincipal(false));

        imagemPrincipal.setPrincipal(true);

        IngredienteEntity ingredienteSalvo = ingredienteRepository.save(ingrediente);

        return new IngredienteResponseDTO(ingredienteSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — REMOVER
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public IngredienteResponseDTO removerImagemDoIngrediente(
            Long idIngrediente,
            Long idIngredienteImagem
    ) {
        IngredienteEntity ingrediente = buscarIngredienteEntityObrigatorio(idIngrediente);

        IngredienteImagemEntity imagemParaRemover = ingrediente.getImagens()
                .stream()
                .filter(imagem -> imagem.getIdIngredienteImagem().equals(idIngredienteImagem))
                .findFirst()
                .orElseThrow(() -> new IngredienteRegraNegocioException(
                        "Imagem não encontrada para este ingrediente."
                ));

        boolean imagemEraPrincipal = Boolean.TRUE.equals(imagemParaRemover.getPrincipal());

        ingrediente.removerImagem(imagemParaRemover);

        if (imagemEraPrincipal && !ingrediente.getImagens().isEmpty()) {
            ingrediente.getImagens()
                    .stream()
                    .min(Comparator.comparing(IngredienteImagemEntity::getOrdem)
                            .thenComparing(IngredienteImagemEntity::getIdIngredienteImagem))
                    .ifPresent(imagem -> imagem.setPrincipal(true));
        }

        IngredienteEntity ingredienteSalvo = ingredienteRepository.save(ingrediente);

        return new IngredienteResponseDTO(ingredienteSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS — BUSCAS
    // ─────────────────────────────────────────────────────────────

    private CategoriaIngredienteEntity buscarCategoriaEntityObrigatoria(Long idCategoriaIngrediente) {
        if (idCategoriaIngrediente == null) {
            throw new CategoriaIngredienteNaoEncontradaException(
                    "ID da categoria de ingrediente não informado."
            );
        }

        return categoriaIngredienteRepository.findById(idCategoriaIngrediente)
                .orElseThrow(() -> new CategoriaIngredienteNaoEncontradaException(idCategoriaIngrediente));
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
            existe = categoriaIngredienteRepository.existsByNomeIgnoreCase(nomeLimpo);
        } else {
            existe = categoriaIngredienteRepository
                    .existsByNomeIgnoreCaseAndIdCategoriaIngredienteNot(
                            nomeLimpo,
                            idCategoriaIgnorada
                    );
        }

        if (existe) {
            throw new IngredienteRegraNegocioException(
                    "Já existe uma categoria de ingrediente com este nome."
            );
        }
    }

    private void validarNomeIngredienteDuplicado(String nome, Long idIngredienteIgnorado) {
        String nomeLimpo = limparObrigatorio(nome, "O nome do ingrediente é obrigatório.");

        boolean existe;

        if (idIngredienteIgnorado == null) {
            existe = ingredienteRepository.existsByNomeIgnoreCase(nomeLimpo);
        } else {
            existe = ingredienteRepository.existsByNomeIgnoreCaseAndIdIngredienteNot(
                    nomeLimpo,
                    idIngredienteIgnorado
            );
        }

        if (existe) {
            throw new IngredienteRegraNegocioException(
                    "Já existe um ingrediente com este nome."
            );
        }
    }

    private void validarCategoriaSemIngredientesAtivos(Long idCategoriaIngrediente) {
        boolean existeIngredienteAtivo =
                ingredienteCategoriaRepository
                        .existsByCategoriaIngrediente_IdCategoriaIngredienteAndIngrediente_AtivoTrue(
                                idCategoriaIngrediente
                        );

        if (existeIngredienteAtivo) {
            throw new IngredienteRegraNegocioException(
                    "Não é possível desativar esta categoria porque existem ingredientes ativos associados."
            );
        }
    }

    private BigDecimal resolverPrecoAdicional(BigDecimal precoAdicional) {
        BigDecimal valor = precoAdicional != null ? precoAdicional : BigDecimal.ZERO;

        if (valor.compareTo(BigDecimal.ZERO) < 0) {
            throw new IngredienteRegraNegocioException(
                    "O preço adicional não pode ser negativo."
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
            throw new IngredienteRegraNegocioException(
                    "A quantidade em estoque não pode ser negativa."
            );
        }

        return quantidade;
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS — CATEGORIAS DO INGREDIENTE
    // ─────────────────────────────────────────────────────────────

    private void aplicarCategoriasNoIngrediente(
            IngredienteEntity ingrediente,
            List<Long> idCategoriasIngrediente,
            boolean substituirCategoriasAtuais
    ) {
        if (substituirCategoriasAtuais) {
            ingrediente.limparCategorias();
        }

        if (idCategoriasIngrediente == null || idCategoriasIngrediente.isEmpty()) {
            return;
        }

        Set<Long> idsUnicos = new LinkedHashSet<>(idCategoriasIngrediente);

        int ordem = 0;

        for (Long idCategoriaIngrediente : idsUnicos) {
            CategoriaIngredienteEntity categoria =
                    buscarCategoriaEntityObrigatoria(idCategoriaIngrediente);

            if (Boolean.FALSE.equals(categoria.getAtivo())) {
                throw new IngredienteRegraNegocioException(
                        "Não é possível associar uma categoria de ingrediente inativa."
                );
            }

            boolean principal = ordem == 0;

            IngredienteCategoriaEntity ingredienteCategoria =
                    IngredienteCategoriaEntity.builder()
                            .ingrediente(ingrediente)
                            .categoriaIngrediente(categoria)
                            .principal(principal)
                            .ordem(ordem)
                            .build();

            ingrediente.adicionarCategoria(ingredienteCategoria);

            ordem++;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS — IMAGENS
    // ─────────────────────────────────────────────────────────────

    private void aplicarImagensNoIngrediente(
            IngredienteEntity ingrediente,
            List<IngredienteRequestDTO.IngredienteImagemRequestDTO> imagensDto
    ) {
        if (imagensDto == null || imagensDto.isEmpty()) {
            return;
        }

        int indicePrincipal = resolverIndiceImagemPrincipal(imagensDto);

        for (int i = 0; i < imagensDto.size(); i++) {
            IngredienteRequestDTO.IngredienteImagemRequestDTO imagemDto = imagensDto.get(i);

            String imagemUrl = limparObrigatorio(
                    imagemDto.imagemUrl(),
                    "A URL da imagem é obrigatória quando uma imagem é enviada."
            );

            IngredienteImagemEntity imagem = IngredienteImagemEntity.builder()
                    .ingrediente(ingrediente)
                    .imagemUrl(imagemUrl)
                    .legenda(limparOpcional(imagemDto.legenda()))
                    .principal(i == indicePrincipal)
                    .ordem(imagemDto.ordem() != null ? imagemDto.ordem() : i)
                    .build();

            ingrediente.adicionarImagem(imagem);
        }
    }

    private int resolverIndiceImagemPrincipal(
            List<IngredienteRequestDTO.IngredienteImagemRequestDTO> imagensDto
    ) {
        for (int i = 0; i < imagensDto.size(); i++) {
            if (Boolean.TRUE.equals(imagensDto.get(i).principal())) {
                return i;
            }
        }

        return 0;
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS — TEXTO
    // ─────────────────────────────────────────────────────────────

    private String limparObrigatorio(String valor, String mensagemErro) {
        String valorLimpo = limparOpcional(valor);

        if (valorLimpo == null) {
            throw new IngredienteRegraNegocioException(mensagemErro);
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