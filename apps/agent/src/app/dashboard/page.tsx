'use client'

import { listen } from '@tauri-apps/api/event'
import { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import type { AppDispatch, RootState } from '../../lib/store'

import { addApplication, loadApplications } from '../../lib/features/dashboard-slice'
import ApplicationList from './application-list'
import NoApplications from './no-applications'

export default function Home(): JSX.Element {
  const dispatch = useDispatch<AppDispatch>()

  const applications = useSelector((state: RootState) => state.dashboard.applications)
  const applicationsLoaded = useSelector((state: RootState) => state.dashboard.applicationsLoaded)

  useEffect(() => {
    listen('run-requested', (e) => {
      dispatch(addApplication(e.payload as string))
    })

    dispatch(loadApplications())
  }, [dispatch])

  return (
    <main className="h-full">
      {
        applications.length > 0
          ? <ApplicationList />
          : (applicationsLoaded && applications.length === 0)
              ? <NoApplications />
              : null
      }
    </main>
  )
}
