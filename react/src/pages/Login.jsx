// src/pages/Login.jsx

import { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  // ArrowLeft,
  Eye,
  EyeOff,
  LockKeyhole,
  LogIn,
  Mail,
  ShieldCheck,
  UserPlus,
} from 'lucide-react';

import { useCliente } from '../hooks/useCliente';

import {
  AppButton,
  AppInput,
  AuthCard,
  ErroBox,
} from '../components/ui/AppUi';

export function LoginPage() {
  const location = useLocation();

  const {
    executarLogin,
    carregando,
    erro,
    limparErro,
  } = useCliente();

  const [credencial, setCredencial] = useState('');
  const [senha, setSenha] = useState('');
  const [mostrarSenha, setMostrarSenha] = useState(false);
  const [erroLocal, setErroLocal] = useState('');

  const mensagem = location.state?.mensagem;
  const destinoTentado = location.state?.from;

  async function handleSubmit(event) {
    event.preventDefault();

    console.info('[LoginPage] SUBMIT_LOGIN_INICIO', {
      credencial,
      destinoTentado,
    });

    setErroLocal('');
    limparErro?.();

    const credencialLimpa = credencial.trim();

    if (!credencialLimpa) {
      setErroLocal('Informe o email ou telefone.');
      return;
    }

    if (!senha) {
      setErroLocal('Informe a senha.');
      return;
    }

    try {
      await executarLogin({
        credencial: credencialLimpa,
        senha,
        destinoTentado,
      });

      console.info('[LoginPage] SUBMIT_LOGIN_SUCESSO', {
        credencial: credencialLimpa,
      });
    } catch (error) {
      console.error('[LoginPage] SUBMIT_LOGIN_ERRO', {
        status: error?.status,
        message: error?.message,
        data: error?.data,
      });

      setErroLocal(
        error?.message ||
          'Não foi possível iniciar sessão. Verifique os dados e tente novamente.'
      );
    }
  }

  return (
    <div className="page-center login-page">
      <AuthCard
        badge="ÁREA DO CLIENTE"
        icon={<ShieldCheck size={34} />}
        title="Entrar na sua conta"
        subtitle="Use o seu email ou telefone para aceder ao menu, pedidos e dados da sua conta."
      >
        {/* <Link className="auth-back-link" to="/menu">
  <ArrowLeft size={17} />
  Voltar ao menu
</Link> */}
        {mensagem && (
          <div className="login-message login-message--success">
            {mensagem}
          </div>
        )}

        <ErroBox message={erroLocal || erro} />

        <form className="login-form" onSubmit={handleSubmit}>
          <AppInput
            label="Email ou telefone"
            value={credencial}
            onChange={(event) => setCredencial(event.target.value)}
            placeholder="ex: cliente@email.com ou 840000000"
            icon={<Mail size={19} />}
            autoComplete="username"
            disabled={carregando}
          />

          <AppInput
            label="Senha"
            value={senha}
            onChange={(event) => setSenha(event.target.value)}
            type={mostrarSenha ? 'text' : 'password'}
            placeholder="Digite a sua senha"
            icon={<LockKeyhole size={19} />}
            autoComplete="current-password"
            disabled={carregando}
            rightElement={
              <button
                type="button"
                className="login-password-toggle"
                onClick={() => setMostrarSenha((value) => !value)}
                disabled={carregando}
                aria-label={mostrarSenha ? 'Ocultar senha' : 'Mostrar senha'}
              >
                {mostrarSenha ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            }
          />

          <AppButton
            type="submit"
            fullWidth
            loading={carregando}
            icon={<LogIn size={19} />}
          >
            Entrar
          </AppButton>
        </form>

        <div className="login-helper">
          <p>
            Cliente criado pelo balcão/admin? Use a senha padrão{' '}
            <strong>12345678</strong> no primeiro acesso. Depois será obrigado
            a definir uma nova senha.
          </p>
        </div>

        <div className="login-footer">
          <span>Ainda não tem conta?</span>

          <Link to="/cliente/cadastro">
            <UserPlus size={17} />
            Criar conta
          </Link>
        </div>
      </AuthCard>
    </div>
  );
}