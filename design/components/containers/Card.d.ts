export interface CardProps {
  children: React.ReactNode;
  /** 16px inner padding; leave false when filling with ListRows */
  padded?: boolean;
  style?: React.CSSProperties;
}
export declare function Card(props: CardProps): JSX.Element;
