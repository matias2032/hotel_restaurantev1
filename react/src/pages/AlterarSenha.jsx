// src/pages/AlterarSenha.jsx

import { useMemo, useState } from 'react';
import {
  Eye,
  EyeOff,
  KeyRound,
  LockKeyhole,
  ShieldCheck,
} from 'lucide-react';

import { useCliente } from '../hooks/useCliente';

import {
  AppButton,
  AppInput,
  AuthCard,
  ErroBox,
} from '../components/ui/AppUi';

export function AlterarSenhaPage() {
  const {
    executarAlterarSenha,
    analisarSenha,
    carregando,
    erro,
    limparErro,
  } = useCliente();

  const [senhaActual, setSenhaActual] = useState('');
  const [novaSenha, setNovaSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');

  const [mostrarSenhaActual, setMostrarSenhaActual] = useState(false);
  const [mostrarNovaSenha, setMostrarNovaSenha] = useState(false);
  const [mostrarConfirmarSenha, setMostrarConfirmarSenha] = useState(false);

  const [erroLocal, setErroLocal] = useState('');

  const analiseSenha = useMemo(
    () => analisarSenha(novaSenha, confirmarSenha),
    [novaSenha, confirmarSenha, analisarSenha]
  );

  async function handleSubmit(event) {
    event.preventDefault();

    console.info('[AlterarSenhaPage] SUBMIT_ALTERAR_SENHA_INICIO');

    setErroLocal('');
    limparErro?.();

    if (!senhaActual) {
      setErroLocal('Informe a senha actual.');
      return;
    }

    if (!novaSenha) {
      setErroLocal('Informe a nova senha.');
      return;
    }

    if (!confirmarSenha) {
      setErroLocal('Confirme a nova senha.');
      return;
    }

    if (novaSenha !== confirmarSenha) {
      setErroLocal('A confirmação da nova senha não confere.');
      return;
    }

    if (senhaActual === novaSenha) {
      setErroLocal('A nova senha deve ser diferente da senha actual.');
      return;
    }

    if (!analiseSenha.senhaValida) {
      setErroLocal('A nova senha ainda não cumpre os requisitos mínimos.');
      return;
    }

    try {
      await executarAlterarSenha({
        senhaActual,
        novaSenha,
      });

      console.info('[AlterarSenhaPage] SUBMIT_ALTERAR_SENHA_SUCESSO');
    } catch (error) {
      console.error('[AlterarSenhaPage] SUBMIT_ALTERAR_SENHA_ERRO', {
        status: error?.status,
        message: error?.message,
        data: error?.data,
      });

      setErroLocal(
        error?.message ||
          'Não foi possível alterar a senha. Verifique os dados e tente novamente.'
      );
    }
  }

  return (
    <div className="page-center alterar-senha-page">
      <AuthCard
        badge="SEGURANÇA"
        icon={<ShieldCheck size={34} />}
        title="Alterar senha"
        subtitle="Depois de alterar a senha, será necessário fazer login novamente."
      >
        <ErroBox message={erroLocal || erro} />

        <form className="alterar-senha-form" onSubmit={handleSubmit}>
          <AppInput
            label="Senha actual"
            value={senhaActual}
            onChange={(event) => setSenhaActual(event.target.value)}
            type={mostrarSenhaActual ? 'text' : 'password'}
            placeholder="Digite a senha actual"
            icon={<LockKeyhole size={19} />}
            autoComplete="current-password"
            disabled={carregando}
            rightElement={
              <button
                type="button"
                className="page-password-toggle"
                onClick={() => setMostrarSenhaActual((value) => !value)}
                disabled={carregando}
                aria-label={
                  mostrarSenhaActual ? 'Ocultar senha' : 'Mostrar senha'
                }
              >
                {mostrarSenhaActual ? (
                  <EyeOff size={18} />
                ) : (
                  <Eye size={18} />
                )}
              </button>
            }
          />

          <AppInput
            label="Nova senha"
            value={novaSenha}
            onChange={(event) => setNovaSenha(event.target.value)}
            type={mostrarNovaSenha ? 'text' : 'password'}
            placeholder="Digite a nova senha"
            icon={<KeyRound size={19} />}
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
            icon={<ShieldCheck size={19} />}
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
            Alterar senha
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
        <span>Força da nova senha</span>

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