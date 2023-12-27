interface HeaderParams {
  className?: string
  title: string
}

export function Header({ className, title }: HeaderParams) {
  return (
    <header className={`prose tracking-wider text-xs md:text-lg ${className}`}>
      <h1>{title}</h1>
    </header>
  )
}
