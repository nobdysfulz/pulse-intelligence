import { SignUp } from '@clerk/nextjs'

export default function SignUpPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-900 px-4 py-12">
      <div className="w-full max-w-md rounded-2xl bg-white/10 p-8 backdrop-blur">
        <h1 className="mb-6 text-center text-3xl font-bold text-white">
          Join Pulse Intelligence
        </h1>
        <SignUp appearance={{ elements: { formButtonPrimary: 'bg-violet-600 hover:bg-violet-700' } }} />
      </div>
    </div>
  )
}
