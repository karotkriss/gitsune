export interface LabelProps {
  /** Label text; "scope::value" renders GitLab's two-tone scoped-label pill */
  name: string;
  /** Label color (any CSS color); text auto-contrasts */
  color?: string;
  onRemove?: () => void;
  style?: React.CSSProperties;
}
export declare function Label(props: LabelProps): JSX.Element;
