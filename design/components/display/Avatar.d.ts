export interface AvatarProps {
  /** Image URL; falls back to tinted initials when absent */
  src?: string;
  name: string;
  /** user → circle; project | group → rounded square */
  entity?: 'user' | 'project' | 'group';
  /** Pixel size: 16, 24, 32, 48, 64, 96 */
  size?: number;
  style?: React.CSSProperties;
}
export declare function Avatar(props: AvatarProps): JSX.Element;
