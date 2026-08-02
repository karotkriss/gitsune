export interface TabBarProps {
  items: Array<{ id: string; icon: string; label: string; badge?: number | string }>;
  active: string;
  onChange?: (id: string) => void;
  /** Absolute-position the capsule over the content (default). Set false to place it in flow (specimens). */
  floating?: boolean;
  style?: React.CSSProperties;
}
export declare function TabBar(props: TabBarProps): JSX.Element;
