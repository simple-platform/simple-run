import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { md5 } from 'hash-wasm'
import { Store } from 'tauri-plugin-store-api'

export interface AppInfo {
  file_to_run: string
  org: string
  repo: string
}

export interface Application extends Omit<AppInfo, 'file_to_run'> {
  fileToRun: string
  id: string
}

const stores = {
  applications: new Store('applications.dat'),
}

const initialState = {
  applications: <Application[]>[],
  applicationsLoaded: false,
}

async function buildApplication(appInfo: AppInfo): Promise<Application | undefined> {
  const provider = 'https://github.com'
  const { file_to_run, org, repo } = appInfo

  return {
    fileToRun: file_to_run,
    id: await md5(`${provider}/${org}/${repo}`),
    org,
    repo,
  }
}

export const loadApplications = createAsyncThunk('dashboard/loadApplications', async () => {
  return (await stores.applications.entries()) as [key: string, value: Omit<Application, 'id'>][]
})

export const addApplication = createAsyncThunk('dashboard/addApplication', async (appInfo: AppInfo) => {
  const application = await buildApplication(appInfo)
  if (!application)
    return

  const { id, ...value } = application
  await stores.applications.set(id, value)
  await stores.applications.save()

  return application
})

export const dashboard = createSlice({
  extraReducers(builder) {
    builder
      .addCase(loadApplications.fulfilled, (state, action) => {
        state.applications = action.payload.map(([id, application]) => ({ id, ...application }))
        state.applicationsLoaded = true
      })
      .addCase(addApplication.fulfilled, (state, action) => {
        if (!action.payload)
          return

        state.applications.push(action.payload)
      })
  },

  initialState,
  name: 'dashboard',

  reducers: {},
})

// export const { } = dashboard.actions
export default dashboard.reducer
