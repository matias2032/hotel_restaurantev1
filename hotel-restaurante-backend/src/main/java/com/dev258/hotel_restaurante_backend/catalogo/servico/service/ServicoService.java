package com.dev258.hotel_restaurante_backend.catalogo.servico.service;

import com.dev258.hotel_restaurante_backend.catalogo.servico.dto.CategoriaServicoRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.servico.dto.CategoriaServicoResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.servico.dto.ServicoRequestDTO;
import com.dev258.hotel_restaurante_backend.catalogo.servico.dto.ServicoResponseDTO;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.CategoriaServicoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoImagemEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.exception.CategoriaServicoNaoEncontradaException;
import com.dev258.hotel_restaurante_backend.catalogo.servico.exception.ServicoNaoEncontradoException;
import com.dev258.hotel_restaurante_backend.catalogo.servico.exception.ServicoRegraNegocioException;
import com.dev258.hotel_restaurante_backend.catalogo.servico.repository.CategoriaServicoRepository;
import com.dev258.hotel_restaurante_backend.catalogo.servico.repository.ServicoImagemRepository;
import com.dev258.hotel_restaurante_backend.catalogo.servico.repository.ServicoRepository;
import com.dev258.hotel_restaurante_backend.catalogo.servico.entity.ServicoCategoriaEntity;
import com.dev258.hotel_restaurante_backend.catalogo.servico.repository.ServicoCategoriaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.LinkedHashSet;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class ServicoService {

    private final CategoriaServicoRepository categoriaServicoRepository;
    private final ServicoRepository servicoRepository;
    private final ServicoImagemRepository servicoImagemRepository;
    private final ServicoCategoriaRepository servicoCategoriaRepository;

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<CategoriaServicoResponseDTO> listarCategorias(Boolean somenteAtivas) {
        List<CategoriaServicoEntity> categorias = Boolean.TRUE.equals(somenteAtivas)
                ? categoriaServicoRepository.findByAtivoTrueOrderByOrdemAscNomeAsc()
                : categoriaServicoRepository.findAllByOrderByOrdemAscNomeAsc();

        return categorias
                .stream()
                .map(CategoriaServicoResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — BUSCAR POR ID
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public CategoriaServicoResponseDTO buscarCategoriaPorId(Long idCategoriaServico) {
        CategoriaServicoEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaServico);
        return new CategoriaServicoResponseDTO(categoria);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — CRIAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public CategoriaServicoResponseDTO criarCategoria(CategoriaServicoRequestDTO dto) {
        validarNomeCategoriaDuplicado(dto.nome(), null);

        CategoriaServicoEntity categoria = CategoriaServicoEntity.builder()
                .nome(limparObrigatorio(dto.nome(), "O nome da categoria é obrigatório."))
                .descricao(limparOpcional(dto.descricao()))
                .ordem(dto.ordem() != null ? dto.ordem() : 0)
                .ativo(dto.ativo() != null ? dto.ativo() : true)
                .build();

        CategoriaServicoEntity categoriaSalva = categoriaServicoRepository.save(categoria);

        return new CategoriaServicoResponseDTO(categoriaSalva);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — EDITAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public CategoriaServicoResponseDTO editarCategoria(
            Long idCategoriaServico,
            CategoriaServicoRequestDTO dto
    ) {
        CategoriaServicoEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaServico);

        validarNomeCategoriaDuplicado(dto.nome(), idCategoriaServico);

        categoria.setNome(limparObrigatorio(dto.nome(), "O nome da categoria é obrigatório."));
        categoria.setDescricao(limparOpcional(dto.descricao()));
        categoria.setOrdem(dto.ordem() != null ? dto.ordem() : 0);
        categoria.setAtivo(dto.ativo() != null ? dto.ativo() : true);

        CategoriaServicoEntity categoriaSalva = categoriaServicoRepository.save(categoria);

        return new CategoriaServicoResponseDTO(categoriaSalva);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — ALTERAR ESTADO
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public CategoriaServicoResponseDTO alterarEstadoCategoria(
            Long idCategoriaServico,
            Boolean ativo
    ) {
        CategoriaServicoEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaServico);

        boolean vaiDesativar = Boolean.FALSE.equals(ativo);

        if (vaiDesativar) {
            validarCategoriaSemServicosAtivos(idCategoriaServico);
        }

        categoria.setAtivo(ativo != null ? ativo : true);

        CategoriaServicoEntity categoriaSalva = categoriaServicoRepository.save(categoria);

        return new CategoriaServicoResponseDTO(categoriaSalva);
    }

    // ─────────────────────────────────────────────────────────────
    // CATEGORIAS — REMOVER LÓGICO
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public void desativarCategoria(Long idCategoriaServico) {
        CategoriaServicoEntity categoria = buscarCategoriaEntityObrigatoria(idCategoriaServico);

        validarCategoriaSemServicosAtivos(idCategoriaServico);

        categoria.setAtivo(false);
        categoriaServicoRepository.save(categoria);
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — LISTAR
    // ─────────────────────────────────────────────────────────────

@Transactional(readOnly = true)
public List<ServicoResponseDTO> listarServicos(
        Boolean somenteAtivos,
        Boolean somenteDisponiveis,
        Boolean somenteDestaques,
        Long idCategoriaServico
) {
    List<ServicoEntity> servicos;

    boolean deveBuscarSomenteAtivos =
            Boolean.TRUE.equals(somenteAtivos)
                    || Boolean.TRUE.equals(somenteDisponiveis);

    if (idCategoriaServico != null) {
        servicos = deveBuscarSomenteAtivos
                ? servicoRepository
                .findDistinctByCategorias_CategoriaServico_IdCategoriaServicoAndAtivoTrueOrderByNomeAsc(
                        idCategoriaServico
                )
                : servicoRepository
                .findDistinctByCategorias_CategoriaServico_IdCategoriaServicoOrderByNomeAsc(
                        idCategoriaServico
                );
    } else if (Boolean.TRUE.equals(somenteDestaques)) {
        servicos =
                servicoRepository
                        .findByDestaqueTrueAndAtivoTrueOrderByNomeAsc();
    } else if (deveBuscarSomenteAtivos) {
        servicos =
                servicoRepository
                        .findByAtivoTrueOrderByNomeAsc();
    } else {
        servicos =
                servicoRepository
                        .findAllByOrderByNomeAsc();
    }

    return servicos
            .stream()
            .map(ServicoResponseDTO::new)
            .filter(dto ->
                    !Boolean.TRUE.equals(somenteDestaques)
                            || Boolean.TRUE.equals(dto.destaque())
            )
            .filter(dto ->
                    !Boolean.TRUE.equals(somenteDisponiveis)
                            || Boolean.TRUE.equals(
                                    dto.disponivelCalculado()
                            )
            )
            .toList();
}

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — BUSCAR POR ID
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public ServicoResponseDTO buscarServicoPorId(Long idServico) {
        ServicoEntity servico = buscarServicoEntityObrigatorio(idServico);
        return new ServicoResponseDTO(servico);
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — CRIAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ServicoResponseDTO criarServico(ServicoRequestDTO dto) {
        validarNomeServicoDuplicado(dto.nome(), null);



        ServicoEntity servico = ServicoEntity.builder()

                .nome(limparObrigatorio(dto.nome(), "O nome do serviço é obrigatório."))
                .descricao(limparOpcional(dto.descricao()))
                .preco(resolverPreco(dto.preco()))
                .imagemPrincipalUrl(limparOpcional(dto.imagemPrincipalUrl()))

                .destaque(dto.destaque() != null ? dto.destaque() : false)
                .ativo(dto.ativo() != null ? dto.ativo() : true)
                .build();


aplicarCategoriasNoServico(servico,dto.idCategoriasServico(),false);
        aplicarImagensNoServico(servico, dto.imagens());

        ServicoEntity servicoSalvo = servicoRepository.save(servico);

        return new ServicoResponseDTO(servicoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — EDITAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ServicoResponseDTO editarServico(
            Long idServico,
            ServicoRequestDTO dto
    ) {
        ServicoEntity servico = buscarServicoEntityObrigatorio(idServico);

        validarNomeServicoDuplicado(dto.nome(), idServico);



        Boolean ativo = dto.ativo() != null ? dto.ativo() : true;




        servico.setNome(limparObrigatorio(dto.nome(), "O nome do serviço é obrigatório."));
        servico.setDescricao(limparOpcional(dto.descricao()));
        servico.setPreco(resolverPreco(dto.preco()));
        servico.setImagemPrincipalUrl(limparOpcional(dto.imagemPrincipalUrl()));
        servico.setDestaque(dto.destaque() != null ? dto.destaque() : false);
        servico.setAtivo(ativo);


        /*
 * Regra:
 * - dto.idCategoriasServico() == null -> mantém categorias atuais.
 * - dto.idCategoriasServico() == []   -> remove todas as categorias.
 * - dto.idCategoriasServico() com IDs -> substitui pelas categorias enviadas.
 */
if (dto.idCategoriasServico() != null) {
    aplicarCategoriasNoServico(
            servico,
            dto.idCategoriasServico(),
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
            servico.getImagens().clear();
            aplicarImagensNoServico(servico, dto.imagens());
        }

        ServicoEntity servicoSalvo = servicoRepository.save(servico);

        return new ServicoResponseDTO(servicoSalvo);
    }


    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — DESTAQUE
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ServicoResponseDTO alterarDestaqueServico(
            Long idServico,
            Boolean destaque
    ) {
        ServicoEntity servico = buscarServicoEntityObrigatorio(idServico);

        servico.setDestaque(destaque != null ? destaque : false);

        ServicoEntity servicoSalvo = servicoRepository.save(servico);

        return new ServicoResponseDTO(servicoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — ACTIVAR / DESACTIVAR
    // ─────────────────────────────────────────────────────────────

@Transactional
public ServicoResponseDTO alterarEstadoServico(
        Long idServico,
        Boolean ativo
) {
    ServicoEntity servico =
            buscarServicoEntityObrigatorio(idServico);

    servico.setAtivo(
            ativo != null ? ativo : true
    );

    ServicoEntity servicoSalvo =
            servicoRepository.save(servico);

    return new ServicoResponseDTO(servicoSalvo);
}

    // ─────────────────────────────────────────────────────────────
    // SERVIÇOS — REMOVER LÓGICO
    // ─────────────────────────────────────────────────────────────

@Transactional
public void desativarServico(Long idServico) {
    ServicoEntity servico =
            buscarServicoEntityObrigatorio(idServico);

    servico.setAtivo(false);

    servicoRepository.save(servico);
}

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — LISTAR
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<ServicoResponseDTO.ServicoImagemResponseDTO> listarImagensDoServico(
            Long idServico
    ) {
        buscarServicoEntityObrigatorio(idServico);

        return servicoImagemRepository
                .findByServico_IdServicoOrderByPrincipalDescOrdemAscIdServicoImagemAsc(idServico)
                .stream()
                .map(ServicoResponseDTO.ServicoImagemResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — ADICIONAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ServicoResponseDTO adicionarImagemAoServico(
            Long idServico,
            ServicoRequestDTO.ServicoImagemRequestDTO dto
    ) {
        ServicoEntity servico = buscarServicoEntityObrigatorio(idServico);

        String imagemUrl = limparObrigatorio(dto.imagemUrl(), "A URL da imagem é obrigatória.");

        ServicoImagemEntity imagem = ServicoImagemEntity.builder()
                .servico(servico)
                .imagemUrl(imagemUrl)
                .legenda(limparOpcional(dto.legenda()))
                .principal(dto.principal() != null ? dto.principal() : false)
                .ordem(dto.ordem() != null ? dto.ordem() : 0)
                .build();

        if (Boolean.TRUE.equals(imagem.getPrincipal())) {
            servico.getImagens()
                    .forEach(img -> img.setPrincipal(false));
        } else if (servico.getImagens().isEmpty()) {
            imagem.setPrincipal(true);
        }

        servico.adicionarImagem(imagem);

        ServicoEntity servicoSalvo = servicoRepository.save(servico);

        return new ServicoResponseDTO(servicoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — DEFINIR PRINCIPAL
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ServicoResponseDTO definirImagemPrincipal(
            Long idServico,
            Long idServicoImagem
    ) {
        ServicoEntity servico = buscarServicoEntityObrigatorio(idServico);

        ServicoImagemEntity imagemPrincipal = servico.getImagens()
                .stream()
                .filter(imagem -> imagem.getIdServicoImagem().equals(idServicoImagem))
                .findFirst()
                .orElseThrow(() -> new ServicoRegraNegocioException(
                        "Imagem não encontrada para este serviço."
                ));

        servico.getImagens()
                .forEach(imagem -> imagem.setPrincipal(false));

        imagemPrincipal.setPrincipal(true);
        servico.setImagemPrincipalUrl(imagemPrincipal.getImagemUrl());

        ServicoEntity servicoSalvo = servicoRepository.save(servico);

        return new ServicoResponseDTO(servicoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // IMAGENS — REMOVER
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public ServicoResponseDTO removerImagemDoServico(
            Long idServico,
            Long idServicoImagem
    ) {
        ServicoEntity servico = buscarServicoEntityObrigatorio(idServico);

        ServicoImagemEntity imagemParaRemover = servico.getImagens()
                .stream()
                .filter(imagem -> imagem.getIdServicoImagem().equals(idServicoImagem))
                .findFirst()
                .orElseThrow(() -> new ServicoRegraNegocioException(
                        "Imagem não encontrada para este serviço."
                ));

        boolean imagemEraPrincipal = Boolean.TRUE.equals(imagemParaRemover.getPrincipal());

        servico.removerImagem(imagemParaRemover);

        if (imagemEraPrincipal && !servico.getImagens().isEmpty()) {
            servico.getImagens()
                    .stream()
                    .min(Comparator.comparing(ServicoImagemEntity::getOrdem)
                            .thenComparing(ServicoImagemEntity::getIdServicoImagem))
                    .ifPresent(imagem -> {
                        imagem.setPrincipal(true);
                        servico.setImagemPrincipalUrl(imagem.getImagemUrl());
                    });
        }

        if (servico.getImagens().isEmpty()) {
            servico.setImagemPrincipalUrl(null);
        }

        ServicoEntity servicoSalvo = servicoRepository.save(servico);

        return new ServicoResponseDTO(servicoSalvo);
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS — BUSCAS
    // ─────────────────────────────────────────────────────────────

    private CategoriaServicoEntity buscarCategoriaEntityObrigatoria(Long idCategoriaServico) {
        if (idCategoriaServico == null) {
            throw new CategoriaServicoNaoEncontradaException(
                    "ID da categoria de serviço não informado."
            );
        }

        return categoriaServicoRepository.findById(idCategoriaServico)
                .orElseThrow(() -> new CategoriaServicoNaoEncontradaException(idCategoriaServico));
    }

    private ServicoEntity buscarServicoEntityObrigatorio(Long idServico) {
        if (idServico == null) {
            throw new ServicoNaoEncontradoException(
                    "ID do serviço não informado."
            );
        }

        return servicoRepository.findById(idServico)
                .orElseThrow(() -> new ServicoNaoEncontradoException(idServico));
    }


    // ─────────────────────────────────────────────────────────────
    // HELPERS — VALIDAÇÕES
    // ─────────────────────────────────────────────────────────────

    private void validarNomeCategoriaDuplicado(String nome, Long idCategoriaIgnorada) {
        String nomeLimpo = limparObrigatorio(nome, "O nome da categoria é obrigatório.");

        boolean existe;

        if (idCategoriaIgnorada == null) {
            existe = categoriaServicoRepository.existsByNomeIgnoreCase(nomeLimpo);
        } else {
            existe = categoriaServicoRepository
                    .existsByNomeIgnoreCaseAndIdCategoriaServicoNot(
                            nomeLimpo,
                            idCategoriaIgnorada
                    );
        }

        if (existe) {
            throw new ServicoRegraNegocioException(
                    "Já existe uma categoria de serviço com este nome."
            );
        }
    }

    private void validarNomeServicoDuplicado(String nome, Long idServicoIgnorado) {
        String nomeLimpo = limparObrigatorio(nome, "O nome do serviço é obrigatório.");

        boolean existe;

        if (idServicoIgnorado == null) {
            existe = servicoRepository.existsByNomeIgnoreCase(nomeLimpo);
        } else {
            existe = servicoRepository.existsByNomeIgnoreCaseAndIdServicoNot(
                    nomeLimpo,
                    idServicoIgnorado
            );
        }

        if (existe) {
            throw new ServicoRegraNegocioException(
                    "Já existe um serviço com este nome."
            );
        }
    }

private void validarCategoriaSemServicosAtivos(Long idCategoriaServico) {
    boolean existeServicoAtivo =
            servicoCategoriaRepository
                    .existsByCategoriaServico_IdCategoriaServicoAndServico_AtivoTrue(
                            idCategoriaServico
                    );

    if (existeServicoAtivo) {
        throw new ServicoRegraNegocioException(
                "Não é possível desativar esta categoria porque existem serviços ativos associados."
        );
    }
}

    private BigDecimal resolverPreco(BigDecimal preco) {
        BigDecimal valor = preco != null ? preco : BigDecimal.ZERO;

        if (valor.compareTo(BigDecimal.ZERO) < 0) {
            throw new ServicoRegraNegocioException(
                    "O preço do serviço não pode ser negativo."
            );
        }

        return valor;
    }


    // ─────────────────────────────────────────────────────────────
// HELPERS — CATEGORIAS DO SERVIÇO
// ─────────────────────────────────────────────────────────────

private void aplicarCategoriasNoServico(
        ServicoEntity servico,
        List<Long> idCategoriasServico,
        boolean substituirCategoriasAtuais
) {
    if (substituirCategoriasAtuais) {
        servico.limparCategorias();
    }

    if (idCategoriasServico == null || idCategoriasServico.isEmpty()) {
        return;
    }

    Set<Long> idsUnicos = new LinkedHashSet<>(idCategoriasServico);

    if (idsUnicos.size() != idCategoriasServico.size()) {
        throw new ServicoRegraNegocioException(
                "Não é permitido associar a mesma categoria mais de uma vez."
        );
    }

    int ordem = 0;

    for (Long idCategoriaServico : idsUnicos) {
        CategoriaServicoEntity categoria =
                buscarCategoriaEntityObrigatoria(idCategoriaServico);

        if (Boolean.FALSE.equals(categoria.getAtivo())) {
            throw new ServicoRegraNegocioException(
                    "Não é possível associar uma categoria de serviço inativa."
            );
        }

        ServicoCategoriaEntity servicoCategoria =
                ServicoCategoriaEntity.builder()
                        .servico(servico)
                        .categoriaServico(categoria)
                        .principal(ordem == 0)
                        .ordem(ordem)
                        .build();

        servico.adicionarCategoria(servicoCategoria);

        ordem++;
    }
}

    // ─────────────────────────────────────────────────────────────
    // HELPERS — IMAGENS
    // ─────────────────────────────────────────────────────────────

    private void aplicarImagensNoServico(
            ServicoEntity servico,
            List<ServicoRequestDTO.ServicoImagemRequestDTO> imagensDto
    ) {
        if (imagensDto == null || imagensDto.isEmpty()) {
            return;
        }

        int indicePrincipal = resolverIndiceImagemPrincipal(imagensDto);

        for (int i = 0; i < imagensDto.size(); i++) {
            ServicoRequestDTO.ServicoImagemRequestDTO imagemDto = imagensDto.get(i);

            String imagemUrl = limparObrigatorio(
                    imagemDto.imagemUrl(),
                    "A URL da imagem é obrigatória quando uma imagem é enviada."
            );

            boolean principal = i == indicePrincipal;

            ServicoImagemEntity imagem = ServicoImagemEntity.builder()
                    .servico(servico)
                    .imagemUrl(imagemUrl)
                    .legenda(limparOpcional(imagemDto.legenda()))
                    .principal(principal)
                    .ordem(imagemDto.ordem() != null ? imagemDto.ordem() : i)
                    .build();

            if (principal) {
                servico.setImagemPrincipalUrl(imagemUrl);
            }

            servico.adicionarImagem(imagem);
        }
    }

    private int resolverIndiceImagemPrincipal(
            List<ServicoRequestDTO.ServicoImagemRequestDTO> imagensDto
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
            throw new ServicoRegraNegocioException(mensagemErro);
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