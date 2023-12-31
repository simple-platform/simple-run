'use client'

import { listen } from '@tauri-apps/api/event'
import { useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'

import type { AppDispatch, RootState } from '../../lib/store'

import { addProject, loadProjects } from '../../lib/features/dashboard-slice'
import NoProjects from './no-projects'
import ProjectList from './project-list'

export default function Home(): JSX.Element {
  const dispatch = useDispatch<AppDispatch>()

  const projects = useSelector((state: RootState) => state.dashboard.projects)
  const projectsLoaded = useSelector((state: RootState) => state.dashboard.projectsLoaded)

  useEffect(() => {
    listen('run-requested', (e) => {
      dispatch(addProject(e.payload as string))
    })

    dispatch(loadProjects())
  }, [dispatch])

  return (
    <main className="h-full">
      {
        projects.length > 0
          ? <ProjectList />
          : (projectsLoaded && projects.length === 0)
              ? <NoProjects />
              : null
      }
    </main>
  )
}
