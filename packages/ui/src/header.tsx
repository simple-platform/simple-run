export function Header({ className, title }: { className?: string, title: string }) {
  return (
    <header className={`prose tracking-wider text-xs md:text-lg ${className}`}>
      <h1>{title}</h1>
    </header>
  )
}
