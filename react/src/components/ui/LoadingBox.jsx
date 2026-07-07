// src/components/ui/LoadingBox.jsx

import './ui.css';

export function LoadingBox({ message = 'Carregando...' }) {
  return (
    <div className="loading-box">
      <span className="loading-box__spinner" />
      <span>{message}</span>
    </div>
  );
}