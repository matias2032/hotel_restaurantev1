// src/pages/PrimeiraSenha.jsx

import { useMemo, useState } from 'react';
import {
  Eye,
  EyeOff,
  KeyRound,
  LockKeyhole,
  ShieldAlert,
} from 'lucide-react';

import { useCliente } from '../hooks/useCliente';

import {
  AppButton,
  AppInput,
  AuthCard,
  ErroBox,
} from '../components/ui/AppUi';

export function PrimeiraSenhaPage() {
  const {
    cliente,
    nomeCompletoCliente,
    iniciaisCliente,
    executarTrocaPrimeiraSenha,
    analisarSenha,
    carregando,
    erro,
    limparErro,
  } = useCliente();

  const [novaSenha, setNovaSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');
  const [mostrarNovaSenha, setMostrarNovaSenha] = useState(false);
  const [mostrarConfirmarSenha, setMostrarConfirmarSenha] = useState(false);
  const [erroLocal, setErroLocal] = useState('');

  const analiseSenha = useMemo(
    () => analisarSenha(novaSenha, confirmarSenha),
    [novaSenha, confirmarSenha, analisarSenha]
  );

  async function handleSubmit(event) {
    event.preventDefault();

    console.info('[PrimeiraSenhaPage] SUBMIT_PRIMEIRA_SENHA_INICIO', {
      idCliente: cliente?.idCliente,
    });

    setErroLocal('');
    limparErro?.();

    if (!novaSenha) {
      setErroLocal('Informe a nova senha.');
      return;
    }

    if (!confirmarSenha) {
      setErroLocal('Confirme a nova senha.');
      return;
    }

    if (novaSenha !== confirmarSenha) {
      setErroLocal('A confirmação da senha não confere.');
      return;
    }

    if (!analiseSenha.senhaValida) {
      setErroLocal('A nova senha ainda não cumpre os requisitos mínimos.');
      return;
    }

    try {
      await executarTrocaPrimeiraSenha({
        novaSenha,
      });

      console.info('[PrimeiraSenhaPage] SUBMIT_PRIMEIRA_SENHA_SUCESSO', {
        idCliente: cliente?.idCliente,
      });
    } catch (error) {
      console.error('[PrimeiraSenhaPage] SUBMIT_PRIMEIRA_SENHA_ERRO', {
        status: error?.status,
        message: error?.message,
        data: error?.data,
      });

      setErroLocal(
        error?.message ||
          'Não foi possível definir a nova senha. Tente novamente.'
      );
    }
  }

  return (
    <div className="page-center primeira-senha-page">
      <AuthCard
        badge="ACÇÃO OBRIGATÓRIA"
        icon={<ShieldAlert size={34} />}
        title="Defina a sua nova senha"
        subtitle="Por segurança, altere a senha padrão antes de continuar a usar a sua conta."
      >
        <div className="primeira-senha-user">
          <div className="primeira-senha-user__avatar">
            {iniciaisCliente}
          </div>

          <div>
            <strong>{nomeCompletoCliente || 'Cliente'}</strong>
            <span>{cliente?.email || cliente?.telefone || 'Sessão activa'}</span>
          </div>
        </div>

        <ErroBox message={erroLocal || erro} />

        <form className="primeira-senha-form" onSubmit={handleSubmit}>
          <AppInput
            label="Nova senha"
            value={novaSenha}
            onChange={(event) => setNovaSenha(event.target.value)}
            type={mostrarNovaSenha ? 'text' : 'password'}
            placeholder="Digite a nova senha"
            icon={<LockKeyhole size={19} />}
            autoComplete="new-password"
            disabled={carregando}
            rightElement={
              <button
                type="button"
                className="page-password-toggle"
                onClick={() => setMostrarNovaSenha((value) => !value)}
                disabled={carregando}
                aria-label={
                  mostrarNovaSenha ? 'Ocultar senha' : 'Mostrar senha'
                }
              >
                {mostrarNovaSenha ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            }
          />

          <AppInput
            label="Confirmar nova senha"
            value={confirmarSenha}
            onChange={(event) => setConfirmarSenha(event.target.value)}
            type={mostrarConfirmarSenha ? 'text' : 'password'}
            placeholder="Repita a nova senha"
            icon={<KeyRound size={19} />}
            autoComplete="new-password"
            disabled={carregando}
            rightElement={
              <button
                type="button"
                className="page-password-toggle"
                onClick={() =>
                  setMostrarConfirmarSenha((value) => !value)
                }
                disabled={carregando}
                aria-label={
                  mostrarConfirmarSenha ? 'Ocultar senha' : 'Mostrar senha'
                }
              >
                {mostrarConfirmarSenha ? (
                  <EyeOff size={18} />
                ) : (
                  <Eye size={18} />
                )}
              </button>
            }
          />

          <SenhaRequisitos analiseSenha={analiseSenha} />

          <AppButton
            type="submit"
            fullWidth
            loading={carregando}
            icon={<KeyRound size={19} />}
          >
            Guardar nova senha
          </AppButton>
        </form>
      </AuthCard>
    </div>
  );
}

function SenhaRequisitos({ analiseSenha }) {
  const requisitos = analiseSenha.requisitos;

  return (
    <div className="senha-box">
      <div className="senha-box__header">
        <span>Força da senha</span>

        <strong className={analiseSenha.className}>
          {analiseSenha.label || 'Digite uma senha'}
        </strong>
      </div>

      <div className="senha-box__bar">
        <span
          style={{
            width: `${Math.max(analiseSenha.score, 0) * 25}%`,
          }}
        />
      </div>

      <ul className="senha-requisitos">
        <SenhaItem valido={requisitos.minimo8}>
          Mínimo de 8 caracteres
        </SenhaItem>

        <SenhaItem valido={requisitos.diferentePadrao}>
          Diferente da senha padrão 12345678
        </SenhaItem>

        <SenhaItem valido={requisitos.temMaiuscula}>
          Pelo menos uma letra maiúscula
        </SenhaItem>

        <SenhaItem valido={requisitos.temNumero}>
          Pelo menos um número
        </SenhaItem>

        <SenhaItem valido={requisitos.confirmacaoIgual}>
          Confirmação igual à senha
        </SenhaItem>
      </ul>
    </div>
  );
}

function SenhaItem({ valido, children }) {
  return (
    <li className={valido ? 'senha-requisito--ok' : ''}>
      <span>{valido ? '✓' : '•'}</span>
      {children}
    </li>
  );
}