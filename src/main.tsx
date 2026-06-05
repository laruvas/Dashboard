import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import { SettingsProvider } from './i18n/SettingsContext'
import { AuthProvider } from './i18n/AuthContext'
import { ToastProvider } from './components/Toast'
import { ConfirmProvider } from './components/Confirm'
import { CommandPaletteProvider } from './components/CommandPalette'
import './styles/app.css'

const root = document.getElementById('root')
if (!root) throw new Error('Root element #root not found')

ReactDOM.createRoot(root).render(
  <React.StrictMode>
    <SettingsProvider>
      <ToastProvider>
        <AuthProvider>
          <ConfirmProvider>
            <BrowserRouter>
              <CommandPaletteProvider>
                <App />
              </CommandPaletteProvider>
            </BrowserRouter>
          </ConfirmProvider>
        </AuthProvider>
      </ToastProvider>
    </SettingsProvider>
  </React.StrictMode>
)
