'use client'

import { useAppStore } from '../../lib/store'

export function RepoCard() {
  const repoMetadata = useAppStore(state => state.setup.repoMetadata)

  if (!repoMetadata.name)
    return null

  const { desc, iconUrl, name, org } = repoMetadata
  const fullName = `${org}/${name}`

  return (
    <article className="card card-side bg-slate-50 dark:bg-slate-950 shadow-md rounded-md transition">
      <figure className="p-1.5 md:p-3 w-20 min-w-20 md:w-28 md:min-w-28 flex">
        <img alt={fullName} className="rounded-md" src={iconUrl} />
      </figure>
      <div className="card-body p-1.5 md:p-3 !pl-0">
        <h3 className="card-title">{fullName}</h3>
        <p className="text-xs md:text-sm">
          <span className="line-clamp-2">{desc}</span>
        </p>
      </div>
    </article>
  )
}
