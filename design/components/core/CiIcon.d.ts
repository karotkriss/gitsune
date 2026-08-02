export type CiStatus = 'success' | 'failed' | 'running' | 'pending' | 'warning' | 'canceled' | 'skipped' | 'manual' | 'created' | 'scheduled';
export interface CiIconProps {
  /** Pipeline/job status; sets both glyph and semantic color (green/red/blue/orange/neutral) */
  status: CiStatus;
  size?: number;
  style?: React.CSSProperties;
}
export declare function CiIcon(props: CiIconProps): JSX.Element;
