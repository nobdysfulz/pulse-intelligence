import { ClerkProvider, SignedIn, SignedOut } from '@clerk/nextjs'
import './globals.css'
import UserProvider from '@/components/context/UserProvider'
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
        <body className="min-h-screen bg-slate-900">
          <SignedIn>
            <UserProvider>
              <AppLayout>
                {children}
              </AppLayout>
            </UserProvider>
          </SignedIn>
          <SignedOut>
            <main className="min-h-screen flex flex-col">
              {children}
            </main>
          </SignedOut>
        </body>
      </html>
    </ClerkProvider>
  )
}
