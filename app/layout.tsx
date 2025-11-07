import { ClerkProvider } from '@clerk/nextjs'
import './globals.css'
import { UserProvider } from '@/components/context/UserContext'
import AppLayout from '@/components/layout/AppLayout'

export const metadata = {
  title: 'Pulse Intelligence',
  description: 'Real Estate Coaching Platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body>
          <UserProvider>
            <AppLayout>
              {children}
            </AppLayout>
          </UserProvider>
        </body>
      </html>
    </ClerkProvider>
  )
}
