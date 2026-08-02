import React from 'react';
import { Icon } from '../core/Icon.jsx';

const V = {
  neutral: ['var(--gl-background-color-strong)', 'var(--gl-text-color-default)'],
  info: ['var(--gl-feedback-info-background-color)', 'var(--gl-feedback-info-text-color)'],
  success: ['var(--gl-feedback-success-background-color)', 'var(--gl-feedback-success-text-color)'],
  warning: ['var(--gl-feedback-warning-background-color)', 'var(--gl-feedback-warning-text-color)'],
  danger: ['var(--gl-feedback-danger-background-color)', 'var(--gl-feedback-danger-text-color)'],
};

/** Pajamas Badge: muted colored pill for states and counts ("Open", "Merged", "3 failed"). */
export function Badge({ variant = 'neutral', icon, children, style }) {
  const [bg, color] = V[variant] || V.neutral;
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, background: bg, color, borderRadius: 'var(--gl-border-radius-full)', padding: '2px 8px', font: 'var(--gs-text-caption)', fontWeight: 'var(--gl-font-weight-bold)', whiteSpace: 'nowrap', ...style }}>
      {icon ? <Icon name={icon} size={12} /> : null}{children}
    </span>
  );
}
