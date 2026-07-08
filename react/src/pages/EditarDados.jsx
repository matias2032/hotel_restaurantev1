// src/pages/EditarDados.jsx

import { useState } from 'react';
import {
  Mail,
  Phone,
  Save,
  User,
} from 'lucide-react';

import { useCliente } from '../hooks/useCliente';

import {
  AppButton,
  AppInput,
  AuthCard,
  ErroBox,
} from '../components/ui/AppUi';

export function EditarDadosPage() {
  const {
    cliente,
    executarEditarDadosCliente,
    carregando,
    erro,
    limparErro,
  } = useCliente();

  const [nome, setNome] = useState(cliente?.nome || '');
  const [apelido, setApelido] = useState(cliente?.apelido || '');
  const [email, setEmail] = useState(cliente?.email || '');
  const [telefone, setTelefone] = useState(cliente?.telefone || '');

  const [erroLocal, setErroLocal] = useState('');

  async function handleSubmit(event) {
    event.preventDefault();

    console.info('[EditarDadosPage] SUBMIT_EDITAR_DADOS_INICIO', {
      idCliente: cliente?.idCliente,
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

    try {
      await executarEditarDadosCliente({
        nome: nomeLimpo,
        apelido: apelidoLimpo,
        email: emailLimpo,
        telefone: telefoneLimpo,
      });

      console.info('[EditarDadosPage] SUBMIT_EDITAR_DADOS_SUCESSO', {
        idCliente: cliente?.idCliente,
      });
    } catch (error) {
      console.error('[EditarDadosPage] SUBMIT_EDITAR_DADOS_ERRO', {
        status: error?.status,
        message: error?.message,
        data: error?.data,
      });

      setErroLocal(
        error?.message ||
          'Não foi possível actualizar os dados. Verifique e tente novamente.'
      );
    }
  }

  return (
    <div className="page-center editar-dados-page">
      <AuthCard
        badge="DADOS DA CONTA"
        icon={<User size={34} />}
        title="Editar dados"
        subtitle="Actualize os seus dados principais. Após guardar, será necessário fazer login novamente."
      >
        {/* <div className="editar-dados-alerta">
          <strong>Atenção</strong>
          <span>
            O perfil e o NUIT não podem ser alterados nesta tela.
          </span>
        </div> */}

        <ErroBox message={erroLocal || erro} />

        <form className="editar-dados-form" onSubmit={handleSubmit}>
          <div className="editar-dados-form__grid">
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

          <AppButton
            type="submit"
            fullWidth
            loading={carregando}
            icon={<Save size={19} />}
          >
            Guardar alterações
          </AppButton>
        </form>
      </AuthCard>
    </div>
  );
}