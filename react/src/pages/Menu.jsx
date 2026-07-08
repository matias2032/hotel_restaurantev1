
// src/pages/Menu.jsx

import {
  Coffee,
  Flame,
  Heart,
  Hotel,
  Minus,
  Plus,
  Search,
  ShoppingCart,
  Star,
  Utensils,
} from 'lucide-react';

import { useCliente } from '../hooks/useCliente';


const categorias = [
  {
    id: 1,
    nome: 'Pratos principais',
    icon: Utensils,
    activo: true,
  },
  {
    id: 2,
    nome: 'Bebidas',
    icon: Coffee,
    activo: false,
  },
  {
    id: 3,
    nome: 'Mais pedidos',
    icon: Flame,
    activo: false,
  },
  {
    id: 4,
    nome: 'Hotel',
    icon: Hotel,
    activo: false,
  },
];

const produtos = [
  {
    id: 1,
    nome: 'Frango grelhado com batata',
    descricao: 'Frango temperado da casa, batata frita e salada fresca.',
    preco: 450,
    categoria: 'Pratos principais',
    destaque: true,
    rating: 4.8,
    tempo: '25 min',
  },
  {
    id: 2,
    nome: 'Hambúrguer especial',
    descricao: 'Pão artesanal, carne suculenta, queijo, ovo e molho especial.',
    preco: 380,
    categoria: 'Mais pedidos',
    destaque: true,
    rating: 4.7,
    tempo: '18 min',
  },
  {
    id: 3,
    nome: 'Peixe grelhado',
    descricao: 'Peixe fresco grelhado, arroz, legumes e molho da casa.',
    preco: 620,
    categoria: 'Pratos principais',
    destaque: false,
    rating: 4.9,
    tempo: '30 min',
  },
  {
    id: 4,
    nome: 'Sumo natural',
    descricao: 'Sumo fresco preparado na hora, sabores variados.',
    preco: 150,
    categoria: 'Bebidas',
    destaque: false,
    rating: 4.6,
    tempo: '5 min',
  },
  {
    id: 5,
    nome: 'Quarto standard',
    descricao: 'Quarto confortável para estadia curta, pequeno-almoço opcional.',
    preco: 3500,
    categoria: 'Hotel',
    destaque: true,
    rating: 4.5,
    tempo: 'Disponível',
  },
  {
    id: 6,
    nome: 'Pizza da casa',
    descricao: 'Pizza média com queijo, fiambre, frango, milho e orégãos.',
    preco: 520,
    categoria: 'Mais pedidos',
    destaque: false,
    rating: 4.7,
    tempo: '22 min',
  },
];

function formatarMoeda(valor) {
  return new Intl.NumberFormat('pt-MZ', {
    style: 'currency',
    currency: 'MZN',
  }).format(valor || 0);
}

export function MenuPage() {
  const {
    autenticado,
    nomeCompletoCliente,
    cliente,
  } = useCliente();

  console.info('[MenuPage] RENDERIZAR_MENU_PUBLICO', {
    autenticado,
    idCliente: cliente?.idCliente,
    nome: nomeCompletoCliente,
  });

  return (
    <div className="menu-page">
      <section className="menu-hero">
        <div className="menu-hero__content">
          <span className="menu-hero__badge">
            <Flame size={16} />
            Aberto agora · Entrega rápida
          </span>

          <h1>
            {autenticado
              ? `Olá, ${nomeCompletoCliente || 'cliente'}`
              : 'Peça comida, reserve serviços e acompanhe tudo online.'}
          </h1>

          <p>
            Explore pratos, bebidas e serviços do hotel restaurante. Esta tela
            ainda usa dados fictícios, mas já está preparada para consumir a API
            quando o módulo de produtos/menu estiver pronto.
          </p>

          <div className="menu-hero__search">
            <Search size={20} />
            <input
              type="text"
              placeholder="Pesquisar pratos, bebidas ou serviços..."
              disabled
            />
            <span>breve</span>
          </div>
        </div>

        <div className="menu-hero__card">
          <div className="menu-hero__card-icon">
            <Utensils size={34} />
          </div>

          <strong>Especial do dia</strong>
          <p>Frango grelhado com batata e salada fresca.</p>

          <div className="menu-hero__price">
            <span>{formatarMoeda(450)}</span>
            <small>25 min</small>
          </div>
        </div>
      </section>

      <section className="menu-categorias">
        {categorias.map((categoria) => {
          const Icon = categoria.icon;

          return (
            <button
              key={categoria.id}
              type="button"
              className={[
                'menu-categoria-card',
                categoria.activo ? 'menu-categoria-card--active' : '',
              ]
                .filter(Boolean)
                .join(' ')}
              onClick={() => {
                console.info('[MenuPage] CATEGORIA_CLICADA', {
                  id: categoria.id,
                  nome: categoria.nome,
                });
              }}
            >
              <Icon size={22} />
              <span>{categoria.nome}</span>
            </button>
          );
        })}
      </section>

      <section className="menu-section-header">
        <div>
          <h2>Menu em destaque</h2>
          <p>Itens ilustrativos para preparar o layout público do cliente.</p>
        </div>

        <button
          type="button"
          className="menu-cart-button"
          onClick={() => {
            console.info('[MenuPage] CARRINHO_CLICADO_DEMO');
          }}
        >
          <ShoppingCart size={18} />
          Carrinho
          <span>0</span>
        </button>
      </section>

      <section className="menu-grid">
        {produtos.map((produto) => (
          <article key={produto.id} className="menu-produto-card">
            <div className="menu-produto-card__image">
              <div className="menu-produto-card__fake-image">
                <Utensils size={34} />
              </div>

              {produto.destaque && (
                <span className="menu-produto-card__badge">
                  Destaque
                </span>
              )}

              <button
                type="button"
                className="menu-produto-card__favorite"
                onClick={() => {
                  console.info('[MenuPage] FAVORITO_CLICADO_DEMO', {
                    idProduto: produto.id,
                    nome: produto.nome,
                  });
                }}
              >
                <Heart size={18} />
              </button>
            </div>

            <div className="menu-produto-card__body">
              <div className="menu-produto-card__meta">
                <span>{produto.categoria}</span>

                <strong>
                  <Star size={14} />
                  {produto.rating}
                </strong>
              </div>

              <h3>{produto.nome}</h3>
              <p>{produto.descricao}</p>

              <div className="menu-produto-card__footer">
                <div>
                  <strong>{formatarMoeda(produto.preco)}</strong>
                  <span>{produto.tempo}</span>
                </div>

                <div className="menu-produto-card__qty">
                  <button
                    type="button"
                    onClick={() => {
                      console.info('[MenuPage] REMOVER_ITEM_DEMO', {
                        idProduto: produto.id,
                        nome: produto.nome,
                      });
                    }}
                  >
                    <Minus size={15} />
                  </button>

                  <span>0</span>

                  <button
                    type="button"
                    onClick={() => {
                      console.info('[MenuPage] ADICIONAR_ITEM_DEMO', {
                        idProduto: produto.id,
                        nome: produto.nome,
                      });
                    }}
                  >
                    <Plus size={15} />
                  </button>
                </div>
              </div>
            </div>
          </article>
        ))}
      </section>
    </div>
  );
}