import React from 'react';
import { Icon } from './Icon.jsx';

const MAP = {
  success: ['status_success', 'var(--gl-status-success-color)'],
  failed: ['status_failed', 'var(--gl-status-danger-color)'],
  running: ['status_running', 'var(--gl-status-info-color)'],
  pending: ['status_pending', 'var(--gl-status-warning-color)'],
  warning: ['status_warning', 'var(--gl-status-warning-color)'],
  canceled: ['status_canceled', 'var(--gl-status-neutral-color)'],
  skipped: ['status_skipped', 'var(--gl-status-neutral-color)'],
  manual: ['status_manual', 'var(--gl-status-neutral-color)'],
  created: ['status_created', 'var(--gl-status-neutral-color)'],
  scheduled: ['status_scheduled', 'var(--gl-status-neutral-color)'],
};

/** GitLab's circular pipeline-status icon. Status→color mapping is fixed product-wide. */
export function CiIcon({ status = 'success', size = 16, style }) {
  const [icon, color] = MAP[status] || MAP.success;
  return <Icon name={icon} size={size} color={color} label={`Pipeline: ${status}`} style={style} />;
}
CiIcon.statuses = Object.keys(MAP);
