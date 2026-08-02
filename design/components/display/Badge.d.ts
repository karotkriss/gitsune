export interface BadgeProps {
  /** Semantic color; neutral default. info=blue, success=green, warning=orange, danger=red */
  variant?: 'neutral' | 'info' | 'success' | 'warning' | 'danger';
  /** Optional leading GitLab icon name, e.g. "issue-open-m", "merge" */
  icon?: string;
  children?: React.ReactNode;
  style?: React.CSSProperties;
}
export declare function Badge(props: BadgeProps): JSX.Element;
