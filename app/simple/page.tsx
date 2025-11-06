export default function Simple() {
  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold">Simple Test Page</h1>
      <p className="text-gray-600 mt-2">If this loads, the basic app is working.</p>
      <a 
        href="/api/test" 
        className="text-blue-600 hover:text-blue-800 mt-4 inline-block"
      >
        Test API
      </a>
    </div>
  )
}
