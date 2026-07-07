// src/components/ui/AppButton.jsx

import './ui.css';

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