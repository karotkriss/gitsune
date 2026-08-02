export interface IconProps {
  /** Glyph name from the vendored GitLab SVG set, e.g. "merge-request", "issues", "todo-done" */
  name: string;
  /** Pixel size. 16 default; render 20–24 inside 44pt touch targets on mobile */
  size?: number;
  /** Look up name in the file-type icon set instead of the UI set */
  file?: boolean;
  /** CSS color; defaults to currentColor */
  color?: string;
  /** Accessible label; omit for decorative icons */
  label?: string;
  style?: React.CSSProperties;
  className?: string;
}
export declare function Icon(props: IconProps): JSX.Element;
