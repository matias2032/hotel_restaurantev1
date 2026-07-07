// src/components/ui/AuthCard.jsx

import './ui.css';

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