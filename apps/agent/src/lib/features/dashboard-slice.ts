import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { md5 } from 'hash-wasm'
import { Store } from 'tauri-plugin-store-api'

interface Project {
  fileToRun: string
  id: string
  org: string
  repo: string
}

const stores = {
  projects: new Store('projects.dat'),
}

const initialState = {
  projects: <Project[]>[],
  projectsLoaded: false,
}

async function buildProject(code: string): Promise<Project | undefined> {
  const provider = 'https://github.com'

  let org = ''
  let repo = ''
  let fileToRun = ''

  code.split('&').forEach((piece) => {
    const [key, val] = piece.split('=')

    if (key === 'o') {
      org = val
      return
    }

    if (key === 'r') {
      repo = val
      return
    }

    if (key === 'f')
      fileToRun = val
  })

  if (org === '' || repo === '')
    return

  return {
    fileToRun,
    id: await md5(`${provider}/${org}/${repo}`),
    org,
    repo,
  }
}

export const loadProjects = createAsyncThunk('dashboard/loadProjects', async () => {
  return (await stores.projects.entries()) as [key: string, value: Omit<Project, 'id'>][]
})

export const addProject = createAsyncThunk('dashboard/addProject', async (request: string) => {
  const code = request.replace('simplerun:gh?', '').trim()
  if (code === '')
    return

  const project = await buildProject(code)
  if (!project)
    return

  const { id, ...value } = project
  await stores.projects.set(id, value)
  await stores.projects.save()

  return project
})

export const dashboard = createSlice({
  extraReducers(builder) {
    builder
      .addCase(loadProjects.fulfilled, (state, action) => {
        state.projects = action.payload.map(([id, project]) => ({ id, ...project }))
        state.projectsLoaded = true
      })
      .addCase(addProject.fulfilled, (state, action) => {
        if (!action.payload)
          return

        state.projects.push(action.payload)
      })
  },

  initialState,
  name: 'dashboard',

  reducers: {},
})

// export const { } = dashboard.actions
export default dashboard.reducer
