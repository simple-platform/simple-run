import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { Store } from 'tauri-plugin-store-api'

interface Project {
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

export const loadProjects = createAsyncThunk('dashboard/loadProjects', async () => {
  return (await stores.projects.entries()) as [key: string, value: Omit<Project, 'id'>][]
})

export const dashboard = createSlice({
  extraReducers(builder) {
    builder.addCase(loadProjects.fulfilled, (state, action) => {
      state.projects = action.payload.map(([id, project]) => ({ id, ...project }))
      state.projectsLoaded = true
    })
  },

  initialState,
  name: 'dashboard',

  reducers: {},
})

// export const { } = dashboard.actions
export default dashboard.reducer
