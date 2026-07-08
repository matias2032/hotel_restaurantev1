// src/pages/Cadastro.jsx

import { useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  ArrowLeft,
  Eye,
  EyeOff,
  LockKeyhole,
  Mail,
  Phone,
  ShieldCheck,
  User,
  UserPlus,
} from 'lucide-react';

import { useCliente } from '../hooks/useCliente';

import {
  AppButton,
  AppInput,
  AuthCard,
  ErroBox,
} from '../components/ui/AppUi';

export function CadastroPage() {
  const {
    executarCadastroCliente,
    analisarSenha,
    carregando,
    erro,
    limparErro,
  } = useCliente();

  const [nome, setNome] = useState('');
  const [apelido, setApelido] = useState('');
  const [email, setEmail] = useState('');
  const [telefone, setTelefone] = useState('');
  const [senha, setSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');

  const [mostrarSenha, setMostrarSenha] = useState(false);
  const [mostrarConfirmarSenha, setMostrarConfirmarSenha] = useState(false);
  const [erroLocal, setErroLocal] = useState('');

  const analiseSenha = useMemo(
    () => analisarSenha(senha, confirmarSenha),
    [senha, confirmarSenha, analisarSenha]
  );

  async function handleSubmit(event) {
    event.preventDefault();

    console.info('[CadastroPage] SUBMIT_CADASTRO_INICIO', {
      nome,
      apelido,
      email,
      telefone,
    });

    setErroLocal('');
    limparErro?.();

    const nomeLimpo = nome.trim();
    const apelidoLimpo = apelido.trim();
    const emailLimpo = email.trim();
    const telefoneLimpo = telefone.trim();

    if (!nomeLimpo) {
      setErroLocal('Informe o nome.');
      return;
    }

    if (!emailLimpo && !telefoneLimpo) {
      setErroLocal('Informe pelo menos o email ou telefone.');
      return;
    }

    if (!senha) {
      setErroLocal('Informe a senha.');
      return;
    }

    if (!confirmarSenha) {
      setErroLocal('Confirme a senha.');
      return;
    }

    if (senha !== confirmarSenha) {
      setErroLocal('A confirmação da senha não confere.');
      return;
    }

    if (!analiseSenha.senhaValida) {
      setErroLocal('A senha ainda não cumpre os requisitos mínimos.');
      return;
    }

    try {
      await executarCadastroCliente({
        nome: nomeLimpo,
        apelido: apelidoLimpo,
        email: emailLimpo,
        telefone: telefoneLimpo,
        senha,
        confirmarSenha,
      });

      console.info('[CadastroPage] SUBMIT_CADASTRO_SUCESSO', {
        nome: nomeLimpo,
        email: emailLimpo,
        telefone: telefoneLimpo,
      });
    } catch (error) {
      console.error('[CadastroPage] SUBMIT_CADASTRO_ERRO', {
        status: error?.status,
        message: error?.message,
        data: error?.data,
      });

      setErroLocal(
        error?.message ||
          'Não foi possível criar a conta. Verifique os dados e tente novamente.'
      );
    }
  }

return (
  <div className="auth-page cadastro-page">
    <div className="auth-page-topbar">
      <Link className="auth-page-back-button" to="/cliente/login">
        <ArrowLeft size={20} />
      </Link>

      <div className="auth-page-topbar__title">
        <strong>Criar conta</strong>
        <span>Volte ao login quando quiser entrar numa conta existente.</span>
      </div>
    </div>

    <div className="auth-page-center">
      <AuthCard
        badge="REGISTO PÚBLICO"
        icon={<UserPlus size={34} />}
        title="Criar conta de cliente"
        subtitle="Crie a sua conta para fazer pedidos, acompanhar serviços e gerir os seus dados."
      >
        <ErroBox message={erroLocal || erro} />

        <form className="cadastro-form" onSubmit={handleSubmit}>
          <div className="cadastro-form__grid">
            <AppInput
              label="Nome"
              value={nome}
              onChange={(event) => setNome(event.target.value)}
              placeholder="Ex: Matias"
              icon={<User size={19} />}
              autoComplete="given-name"
              disabled={carregando}
            />

            <AppInput
              label="Apelido"
              value={apelido}
              onChange={(event) => setApelido(event.target.value)}
              placeholder="Ex: Matavel"
              icon={<User size={19} />}
              autoComplete="family-name"
              disabled={carregando}
            />
          </div>

          <AppInput
            label="Email"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            placeholder="ex: cliente@email.com"
            icon={<Mail size={19} />}
            autoComplete="email"
            disabled={carregando}
          />

          <AppInput
            label="Telefone"
            value={telefone}
            onChange={(event) => setTelefone(event.target.value)}
            placeholder="ex: 840000000"
            icon={<Phone size={19} />}
            autoComplete="tel"
            disabled={carregando}
          />

          <AppInput
            label="Senha"
            value={senha}
            onChange={(event) => setSenha(event.target.value)}
            type={mostrarSenha ? 'text' : 'password'}
            placeholder="Crie uma senha segura"
            icon={<LockKeyhole size={19} />}
            autoComplete="new-password"
            disabled={carregando}
            rightElement={
              <button
                type="button"
                className="page-password-toggle"
                onClick={() => setMostrarSenha((value) => !value)}
                disabled={carregando}
                aria-label={mostrarSenha ? 'Ocultar senha' : 'Mostrar senha'}
              >
                {mostrarSenha ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            }
          />

          <AppInput
            label="Confirmar senha"
            value={confirmarSenha}
            onChange={(event) => setConfirmarSenha(event.target.value)}
            type={mostrarConfirmarSenha ? 'text' : 'password'}
            placeholder="Repita a senha"
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
            icon={<UserPlus size={19} />}
          >
            Criar conta
          </AppButton>
        </form>

        <div className="auth-page-footer">
          <span>Já tem conta?</span>

          <Link to="/cliente/login">
            Entrar agora
          </Link>
        </div>
          </AuthCard>
    </div>
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