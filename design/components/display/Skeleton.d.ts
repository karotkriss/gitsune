export interface SkeletonProps {
  width?: number | string;
  height?: number | string;
  radius?: string;
  /** Renders N stacked bars; the last is 60% width */
  lines?: number;
  gap?: number;
  style?: React.CSSProperties;
}
export declare function Skeleton(props: SkeletonProps): JSX.Element;
