export interface TabsProps {
  tabs: Array<{ id: string; label: string; count?: number }>;
  /** id of the selected tab */
  active: string;
  onChange?: (id: string) => void;
  style?: React.CSSProperties;
}
export declare function Tabs(props: TabsProps): JSX.Element;
