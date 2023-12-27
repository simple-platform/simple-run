import type { TypedUseSelectorHook } from 'react-redux'

import { configureStore } from '@reduxjs/toolkit'
import { useSelector } from 'react-redux'

import setup from './features/setup-slice'

export const store = configureStore({
  reducer: {
    setup,
  },
})

export type AppDispatch = typeof store.dispatch
export type RootState = ReturnType<typeof store.getState>

export const useAppStore: TypedUseSelectorHook<RootState> = useSelector
