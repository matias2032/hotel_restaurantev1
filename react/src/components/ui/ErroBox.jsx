// src/components/ui/ErroBox.jsx

import { AlertCircle } from 'lucide-react';
import './ui.css';

export function ErroBox({ message }) {
  if (!message) return null;

  return (
    <div className="erro-box">
      <AlertCircle size={20} />
      <p>{message}</p>
    </div>
  );
}