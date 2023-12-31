import { useSelector } from 'react-redux'

import type { RootState } from '../../lib/store'

import Application from './application'

export default function ApplicationList() {
  const applications = useSelector((state: RootState) => state.dashboard.applications)

  return (
    <section className="p-8">
      <h1 className="text-2xl font-semibold">Applications</h1>
      <table className="table mt-6">
        <thead>
          <tr>
            <th>
              <label><input className="checkbox" type="checkbox" /></label>
            </th>
            <th className="w-full">Name</th>
            <th>Status</th>
            <th>Last Started</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {applications.map(app => <Application app={app} key={app.id} />)}
        </tbody>
      </table>
    </section>
  )
}
