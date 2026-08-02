export interface TileProps {
  /** Fixed noun→color mapping: issues green, mrs blue, todos orange, pipelines purple, projects neutral, groups dark-blue */
  hue?: 'issues' | 'mrs' | 'todos' | 'pipelines' | 'projects' | 'groups';
  /** Override container color (any CSS color) */
  color?: string;
  /** GitLab glyph name inside the container */
  icon: string;
  label: string;
  count?: number;
  onPress?: () => void;
  divider?: boolean;
}
export declare function Tile(props: TileProps): JSX.Element;
