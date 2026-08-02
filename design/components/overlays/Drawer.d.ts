export interface DrawerProps {
  open: boolean;
  /** Called on scrim tap */
  onClose?: () => void;
  title?: string;
  children?: React.ReactNode;
  style?: React.CSSProperties;
}
export declare function Drawer(props: DrawerProps): JSX.Element | null;
