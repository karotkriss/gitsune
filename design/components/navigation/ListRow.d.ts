export interface ListRowProps {
  /** Leading node: <Icon>, <Avatar>, <CiIcon>, or a Tile-style glyph container */
  leading?: React.ReactNode;
  title: React.ReactNode;
  /** Render title in GitLab Mono (branch names, commit IDs) */
  titleMono?: boolean;
  subtitle?: React.ReactNode;
  /** Right-aligned secondary text, e.g. "13h" */
  meta?: React.ReactNode;
  /** 'chevron' (default), custom node, or null */
  trailing?: React.ReactNode | 'chevron' | null;
  onPress?: () => void;
  divider?: boolean;
  style?: React.CSSProperties;
}
export declare function ListRow(props: ListRowProps): JSX.Element;
