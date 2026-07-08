// src/components/ui/AppUi.jsx

import { AlertCircle } from 'lucide-react';
import './ui.css';

// ─────────────────────────────────────────────────────────────
// BUTTON
// ─────────────────────────────────────────────────────────────

export function AppButton({
  type = 'button',
  children,
  icon,
  loading = false,
  disabled = false,
  variant = 'primary',
  fullWidth = false,
  onClick,
}) {
  const className = [
    'app-button',
    `app-button--${variant}`,
    fullWidth ? 'app-button--full' : '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <button
      type={type}
      className={className}
      disabled={disabled || loading}
      onClick={onClick}
    >
      {loading ? <span className="app-button__spinner" /> : icon}
      <span>{loading ? 'Aguarde...' : children}</span>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// INPUT
// ─────────────────────────────────────────────────────────────

export function AppInput({
  label,
  value,
  onChange,
  type = 'text',
  placeholder,
  icon,
  error,
  disabled = false,
  autoComplete,
  onKeyDown,
  rightElement,
}) {
  return (
    <label className="app-input-group">
      {label && <span className="app-input-label">{label}</span>}

      <span
        className={[
          'app-input-wrap',
          error ? 'app-input-wrap--error' : '',
          disabled ? 'app-input-wrap--disabled' : '',
        ]
          .filter(Boolean)
          .join(' ')}
      >
        {icon && <span className="app-input-icon">{icon}</span>}

        <input
          className="app-input"
          value={value}
          onChange={onChange}
          type={type}
          placeholder={placeholder}
          disabled={disabled}
          autoComplete={autoComplete}
          onKeyDown={onKeyDown}
        />

        {rightElement && (
          <span className="app-input-right">
            {rightElement}
          </span>
        )}
      </span>

      {error && <span className="app-input-error">{error}</span>}
    </label>
  );
}

// ─────────────────────────────────────────────────────────────
// AUTH CARD
// ─────────────────────────────────────────────────────────────

export function AuthCard({
  badge,
  icon,
  title,
  subtitle,
  children,
}) {
  return (
    <div className="auth-card-shell">
      <div className="auth-card-header">
        {badge && <div className="auth-card-badge">{badge}</div>}

        {icon && <div className="auth-card-icon">{icon}</div>}

        <h1>{title}</h1>

        {subtitle && <p>{subtitle}</p>}
      </div>

      <div className="auth-card-body">
        {children}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// ERRO
// ─────────────────────────────────────────────────────────────

export function ErroBox({ message }) {
  if (!message) return null;

  return (
    <div className="erro-box">
      <AlertCircle size={20} />
      <p>{message}</p>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// LOADING
// ─────────────────────────────────────────────────────────────

export function LoadingBox({ message = 'Carregando...' }) {
  return (
    <div className="loading-box">
      <span className="loading-box__spinner" />
      <span>{message}</span>
    </div>
  );
}