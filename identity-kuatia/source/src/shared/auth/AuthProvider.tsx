'use client'

/**
 * Contexto de autenticación de la consola.
 *
 * Hidrata la cuenta con `billingApi.me()` si hay token; limpia sesión en 401/403.
 * Expone login/register/logout/refresh para formularios y `AppShell`.
 */
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { billingApi } from '../api/billing'
import { ApiError } from '../api/client'
import type { Account } from '../types/billing'
import { clearAccessToken, getAccessToken, setAccessToken } from './session'

/** Estado y acciones de auth expuestos por el provider. */
type AuthState = {
  account: Account | null
  loading: boolean
  login: (email: string, password: string) => Promise<void>
  /** Sesión desde JWT OAuth (callback). */
  loginWithToken: (accessToken: string) => Promise<void>
  register: (name: string, email: string, password: string) => Promise<void>
  logout: () => void
  refresh: () => Promise<void>
}

const AuthContext = createContext<AuthState | null>(null)

/** Provider raíz que mantiene la sesión de billing en el árbol React. */
export function AuthProvider({ children }: { children: ReactNode }) {
  const [account, setAccount] = useState<Account | null>(null)
  const [loading, setLoading] = useState(true)

  const refresh = useCallback(async () => {
    const token = getAccessToken()
    if (!token) {
      setAccount(null)
      setLoading(false)
      return
    }
    try {
      const me = await billingApi.me()
      setAccount(me)
    } catch (err) {
      if (err instanceof ApiError && (err.status === 401 || err.status === 403)) {
        clearAccessToken()
      }
      setAccount(null)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void refresh()
  }, [refresh])

  const login = useCallback(async (email: string, password: string) => {
    const res = await billingApi.login({ email, password })
    setAccessToken(res.accessToken)
    setAccount(res.account)
  }, [])

  const loginWithToken = useCallback(async (accessToken: string) => {
    setAccessToken(accessToken)
    const me = await billingApi.me()
    setAccount(me)
  }, [])

  const register = useCallback(async (name: string, email: string, password: string) => {
    const res = await billingApi.register({ name, email, password })
    setAccessToken(res.accessToken)
    setAccount(res.account)
  }, [])

  const logout = useCallback(() => {
    clearAccessToken()
    setAccount(null)
  }, [])

  const value = useMemo(
    () => ({ account, loading, login, loginWithToken, register, logout, refresh }),
    [account, loading, login, loginWithToken, register, logout, refresh],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

/** Hook de auth; debe usarse dentro de `AuthProvider`. */
export function useAuth(): AuthState {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth debe usarse dentro de AuthProvider')
  return ctx
}
