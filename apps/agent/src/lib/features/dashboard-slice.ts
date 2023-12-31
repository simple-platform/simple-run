import type { PayloadAction } from '@reduxjs/toolkit'

import { createSlice } from '@reduxjs/toolkit'

interface Project {
  org: string
  repo: string
}

const initialState = {
  projects: <Project[]>[],
}

export const dashboard = createSlice({
  initialState,
  name: 'dashboard',
  reducers: {
    addProject(state, action: PayloadAction<Project>) {
      state.projects.push(action.payload)
    },
  },
})

export const { addProject } = dashboard.actions
export default dashboard.reducer
