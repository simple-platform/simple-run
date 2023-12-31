import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'
import { md5 } from 'hash-wasm'
import { Store } from 'tauri-plugin-store-api'

export interface Application {
  fileToRun: string
  id: string
  org: string
  repo: string
}

const stores = {
  applications: new Store('applications.dat'),
}

const initialState = {
  applications: <Application[]>[],
  applicationsLoaded: false,
}

async function buildApplication(code: string): Promise<Application | undefined> {
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

export const loadApplications = createAsyncThunk('dashboard/loadApplications', async () => {
  return (await stores.applications.entries()) as [key: string, value: Omit<Application, 'id'>][]
})

export const addApplication = createAsyncThunk('dashboard/addApplication', async (request: string) => {
  const code = request.replace('simplerun:gh?', '').trim()
  if (code === '')
    return

  const application = await buildApplication(code)
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
