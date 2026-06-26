import { IconSearch } from './Icons'

interface SearchBoxProps {
  value: string
  placeholder: string
  onChange: (value: string) => void
  className?: string
}

export default function SearchBox({
  value,
  placeholder,
  onChange,
  className = 'mb-6',
}: SearchBoxProps) {
  return (
    <div
      className={className}
      style={{
        background: 'var(--bg-elev-1)',
        border: '1px solid var(--border)',
        borderRadius: 'var(--r-md)',
        padding: 'var(--s-2) var(--s-3)',
        display: 'flex',
        alignItems: 'center',
        gap: 'var(--s-2)',
        maxWidth: 420,
      }}
    >
      <IconSearch style={{ color: 'var(--text-muted)' }} />
      <input
        type="search"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        style={{
          flex: 1,
          border: 'none',
          outline: 'none',
          background: 'none',
          color: 'var(--text)',
          fontSize: 13,
        }}
      />
    </div>
  )
}
