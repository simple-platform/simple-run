import type { Application as App } from '../../lib/features/dashboard-slice'

interface AppParams {
  app: App
  key: string
}

export default function Application(params: AppParams) {
  const { app: { org, repo } } = params

  const repoUrl = `https://github.com/${org}/${repo}`

  return (
    <tr className="font-normal">
      <td>
        <label><input className="checkbox" type="checkbox" /></label>
      </td>
      <td>
        <div className="font-medium">{`${org}/${repo}`}</div>
        <a className="text-xs link link-hover italic" href={repoUrl} rel="noreferrer" target="_blank">{repoUrl}</a>
      </td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  )
}
