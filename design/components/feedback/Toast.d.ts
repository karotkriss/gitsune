export interface ToastProps {
  children: React.ReactNode;
  /** Action text, e.g. "Undo" */
  action?: string;
  onAction?: () => void;
  style?: React.CSSProperties;
}
export declare function Toast(props: ToastProps): JSX.Element;
