import type { TypedUseSelectorHook } from 'react-redux'

import { configureStore } from '@reduxjs/toolkit'
import { useSelector } from 'react-redux'

import dashboard from './features/dashboard-slice'

export const store = configureStore({
  reducer: {
    dashboard,
  },
})

export type AppDispatch = typeof store.dispatch
export type RootState = ReturnType<typeof store.getState>

export const useAppStore: TypedUseSelectorHook<RootState> = useSelector
