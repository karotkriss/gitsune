import React from 'react';
import { Icon } from '../core/Icon.jsx';

const V = {
  info: ['information-o', 'var(--gl-feedback-info-background-color)', 'var(--gl-status-info-color)'],
  success: ['check-circle', 'var(--gl-feedback-success-background-color)', 'var(--gl-status-success-color)'],
  warning: ['warning', 'var(--gl-feedback-warning-background-color)', 'var(--gl-status-warning-color)'],
  danger: ['error', 'var(--gl-feedback-danger-background-color)', 'var(--gl-status-danger-color)'],
};

/** Pajamas Alert: inline feedback banner. Plain, factual copy — "Pipeline failed", no exclamation marks. */
export function Alert({ variant = 'info', title, children, onDismiss, style }) {
  const [icon, bg, iconColor] = V[variant] || V.info;
  return (
    <div role="alert" style={{ display: 'flex', gap: 12, padding: '12px 16px', background: bg, borderRadius: 'var(--gl-border-radius-lg)', ...style }}>
      <Icon name={icon} size={16} color={iconColor} style={{ marginTop: 2 }} />
      <div style={{ flex: 1, minWidth: 0 }}>
        {title ? <div style={{ fontWeight: 'var(--gl-font-weight-bold)', color: 'var(--gl-text-color-heading)', marginBottom: children ? 4 : 0 }}>{title}</div> : null}
        {children ? <div style={{ color: 'var(--gl-text-color-default)' }}>{children}</div> : null}
      </div>
      {onDismiss ? <button onClick={onDismiss} aria-label="Dismiss" style={{ all: 'unset', cursor: 'pointer', display: 'flex', padding: 4, margin: -4, color: 'var(--gl-icon-color-subtle)', height: 'fit-content' }}><Icon name="close" size={16} /></button> : null}
    </div>
  );
}
