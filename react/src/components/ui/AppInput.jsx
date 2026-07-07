// src/components/ui/AppInput.jsx

import './ui.css';

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