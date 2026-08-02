export interface ButtonProps {
  /** confirm = solid brand orange (primary action, incl. merge); default = neutral outline; danger = solid red (destructive only); ghost = borderless */
  variant?: 'confirm' | 'default' | 'danger' | 'ghost';
  /** sm 32px (inline), md 44px (touch default), lg 50px (full-width CTAs) */
  size?: 'sm' | 'md' | 'lg';
  /** Leading GitLab icon name */
  icon?: string;
  /** Square icon-only button; provide label */
  iconOnly?: boolean;
  loading?: boolean;
  /** Full width */
  block?: boolean;
  disabled?: boolean;
  /** Accessible label (required when iconOnly) */
  label?: string;
  children?: React.ReactNode;
  onClick?: () => void;
  style?: React.CSSProperties;
}
export declare function Button(props: ButtonProps): JSX.Element;
