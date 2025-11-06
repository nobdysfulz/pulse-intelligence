'use client'

import { useState, useEffect } from 'react'

export function PulseDashboardSimple() {
  const [loading, setLoading] = useState(true)
  const [score, setScore] = useState(null)
  const [apiStatus, setApiStatus] = useState('Testing...')

  useEffect(() => {
    testAPI()
  }, [])

  const testAPI = async () => {
    try {
      console.log('🔍 Testing PULSE API...')
      setApiStatus('Calling /api/pulse/score...')
      
      const response = await fetch('/api/pulse/score')
      console.log('📡 API Response status:', response.status)
      setApiStatus(`API Status: ${response.status}`)
      
      if (response.ok) {
        const data = await response.json()
        console.log('✅ API Data received:', data)
        setScore(data.data?.score)
      } else {
        console.error('❌ API Error:', response.status, response.statusText)
        setApiStatus(`API Error: ${response.status} - ${response.statusText}`)
      }
    } catch (error) {
      console.error('💥 API Fetch Error:', error)
      setApiStatus(`Fetch Error: ${error.message}`)
    } finally {
      setLoading(false)
    }
  }

  const generateTestData = async () => {
    try {
      console.log('🛠️ Generating test data...')
      const response = await fetch('/api/pulse/test-data', { method: 'POST' })
      const data = await response.json()
      console.log('📊 Test data response:', data)
      alert(`Test data: ${data.message}`)
      // Retest API after generating data
      await testAPI()
    } catch (error) {
      console.error('💥 Test data error:', error)
      alert('Error generating test data')
    }
  }

  if (loading) {
    return (
      <div className="p-6">
        <div className="text-lg">🔍 Testing PULSE System...</div>
        <div className="text-sm text-gray-600 mt-2">{apiStatus}</div>
        <div className="mt-4 text-xs text-gray-500">
          Open browser console (F12) for detailed logs
        </div>
      </div>
    )
  }

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-3xl font-bold">PULSE Intelligence Debug</h1>
      
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-200">
        <h2 className="text-xl font-bold text-gray-900">API Status</h2>
        <p className="text-gray-600 mt-2">{apiStatus}</p>
        
        {score ? (
          <div className="mt-4 p-4 bg-green-50 border border-green-200 rounded-lg">
            <h3 className="font-semibold text-green-800">✅ Score Loaded!</h3>
            <pre className="text-sm mt-2 whitespace-pre-wrap">
              {JSON.stringify(score, null, 2)}
            </pre>
          </div>
        ) : (
          <div className="mt-4 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
            <h3 className="font-semibold text-yellow-800">⚠️ No Score Data</h3>
            <p className="text-yellow-700 mt-1">
              Check the browser console for detailed error information.
            </p>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <button
          onClick={testAPI}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        >
          🔄 Test API Again
        </button>
        
        <button
          onClick={generateTestData}
          className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
        >
          🛠️ Generate Test Data
        </button>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-2xl p-6">
        <h3 className="font-semibold text-blue-900">Debug Instructions</h3>
        <ol className="text-blue-700 mt-2 space-y-1 text-sm">
          <li>1. Open browser console (F12 → Console tab)</li>
          <li>2. Click "Test API Again" to see detailed logs</li>
          <li>3. If errors, click "Generate Test Data" first</li>
          <li>4. Share the console output with me</li>
        </ol>
      </div>
    </div>
  )
}
