export interface TokenProps {
  children: React.ReactNode;
  /** Optional leading GitLab icon name */
  icon?: string;
  /** Shows the × affordance when provided */
  onRemove?: () => void;
  style?: React.CSSProperties;
}
export declare function Token(props: TokenProps): JSX.Element;
