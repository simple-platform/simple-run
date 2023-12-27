import type { PayloadAction } from '@reduxjs/toolkit'

import { createSlice } from '@reduxjs/toolkit'

export interface RepoMetadata {
  desc: string
  dockerFiles: string[]
  iconUrl: string
  name: string
  org: string
}

const initialState = {
  errors: <string[]>[],
  fileToRun: '',
  repoMetadata: <RepoMetadata>{},
}

export const setup = createSlice({
  initialState,
  name: 'setup',
  reducers: {
    setErrors(state, action: PayloadAction<string[]>) {
      state.errors = action.payload
    },
    setFileToRun(state, action: PayloadAction<string>) {
      state.fileToRun = action.payload
    },
    setRepoMetadata(state, action: PayloadAction<RepoMetadata>) {
      state.errors = []
      state.repoMetadata = action.payload
    },
  },
})

export const { setErrors, setFileToRun, setRepoMetadata } = setup.actions
export default setup.reducer
