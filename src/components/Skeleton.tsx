// Skeleton loaders with a 300ms delay to avoid flashing on fast responses.
// Pulse animation is in app.css.
import { useEffect, useState, type CSSProperties } from 'react'

/* ============== Hook ============== */

/**
 * Returns true only if `active` stays true for at least `delayMs`.
 * Avoids skeleton "flash" when the API responds quickly.
 *
 *   const showSkeleton = useDelayedFlag(loading, 300)
 *   if (showSkeleton) return <SkeletonGrid />
 */
export function useDelayedFlag(active: boolean, delayMs: number = 300): boolean {
  const [shown, setShown] = useState(false)

  useEffect(() => {
    if (!active) {
      setShown(false)
      return
    }
    const id = window.setTimeout(() => setShown(true), delayMs)
    return () => window.clearTimeout(id)
  }, [active, delayMs])

  return shown
}

/* ============== Primitives ============== */

interface SkeletonProps {
  width?: number | string
  height?: number | string
  radius?: number | string
  style?: CSSProperties
  className?: string
}

export function Skeleton({ width, height, radius, style, className = '' }: SkeletonProps) {
  return (
    <div
      className={`skeleton ${className}`.trim()}
      aria-hidden="true"
      style={{
        width: width ?? '100%',
        height: height ?? 14,
        borderRadius: radius,
        ...style,
      }}
    />
  )
}

/* ============== Composite skeletons ============== */

/** A skeleton matching the visual structure of a service card. */
export function SkeletonCard() {
  return (
    <div className="card" style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div className="flex-between mb-4">
        <Skeleton width={70} height={20} radius={999} />
        <Skeleton width={48} height={12} />
      </div>
      <Skeleton width="70%" height={18} style={{ marginBottom: 12 }} />
      <Skeleton width="100%" height={12} style={{ marginBottom: 6 }} />
      <Skeleton width="92%" height={12} style={{ marginBottom: 6 }} />
      <Skeleton width="60%" height={12} />
      <div className="flex-between mt-auto" style={{ paddingTop: 'var(--s-6)' }}>
        <Skeleton width={50} height={18} />
        <Skeleton width={70} height={14} />
      </div>
    </div>
  )
}

/** A grid of SkeletonCards — drops straight into .services-grid. */
export function SkeletonCardGrid({ count = 6 }: { count?: number }) {
  return (
    <div className="services-grid">
      {Array.from({ length: count }, (_, i) => (
        <SkeletonCard key={i} />
      ))}
    </div>
  )
}

/** A skeleton stat tile for Dashboard. */
export function SkeletonStat() {
  return (
    <div className="stat">
      <Skeleton width={80} height={12} />
      <Skeleton width={60} height={28} style={{ marginTop: 10 }} />
      <Skeleton width={100} height={12} style={{ marginTop: 8 }} />
    </div>
  )
}

/** A skeleton row matching a table row layout. */
export function SkeletonTableRow({ cols = 6 }: { cols?: number }) {
  return (
    <tr>
      {Array.from({ length: cols }, (_, i) => (
        <td key={i}>
          <Skeleton height={14} />
        </td>
      ))}
    </tr>
  )
}

/** Generic vertical list of N skeleton lines. */
export function SkeletonList({ count = 5, gap = 12 }: { count?: number; gap?: number }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap }}>
      {Array.from({ length: count }, (_, i) => (
        <Skeleton key={i} height={14} />
      ))}
    </div>
  )
}
