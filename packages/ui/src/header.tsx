export function Header({ className, title }: { className?: string, title: string }) {
  return (
    <header className={`prose tracking-wider text-sm md:text-md ${className}`}>
      <h1>{title}</h1>
    </header>
  )
}
