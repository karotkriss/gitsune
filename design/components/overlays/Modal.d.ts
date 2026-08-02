export interface ModalProps {
  open: boolean;
  onClose?: () => void;
  title: string;
  children?: React.ReactNode;
  /** Action buttons row, e.g. <><Button>Cancel</Button><Button variant="danger">Remove</Button></> */
  actions?: React.ReactNode;
  style?: React.CSSProperties;
}
export declare function Modal(props: ModalProps): JSX.Element | null;
