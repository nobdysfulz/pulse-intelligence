'use client'

import { useState, useEffect } from 'react'

interface PulseScore {
  overall_score: number
  planning_score: number
  urgency_score: number
  lead_engagement_score: number
  systems_score: number
  execution_score: number
  trend_direction: string
  predictive_score: number
  peer_percentile: number
  performance_tier: string
  strongest_pillar: string
  weakest_pillar: string
  calculated_at: string
}

interface Intervention {
  trigger_type: string
  pillar_affected: string
  severity: string
  recommendation: string
  action_steps: string[]
}

export function PulseDashboard() {
  const [score, setScore] = useState<PulseScore | null>(null)
  const [interventions, setInterventions] = useState<Intervention[]>([])
  const [loading, setLoading] = useState(true)
  const [calculating, setCalculating] = useState(false)

  useEffect(() => {
    fetchPulseScore()
  }, [])

  const fetchPulseScore = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/pulse/score')
      
      if (response.ok) {
        const data = await response.json()
        setScore(data.data.score)
        setInterventions(data.data.interventions)
      }
    } catch (error) {
      console.error('Error fetching pulse score:', error)
    } finally {
      setLoading(false)
    }
  }

  const calculateNewScore = async () => {
    try {
      setCalculating(true)
      const response = await fetch('/api/pulse/score', {
        method: 'POST'
      })
      
      if (response.ok) {
        const data = await response.json()
        setScore(data.data.score)
        await fetchPulseScore() // Refresh interventions and history
      }
    } catch (error) {
      console.error('Error calculating pulse score:', error)
    } finally {
      setCalculating(false)
    }
  }

  const generateTestData = async () => {
    try {
      const response = await fetch('/api/pulse/test-data', {
        method: 'POST'
      })
      
      if (response.ok) {
        alert('Test data generated successfully!')
        await calculateNewScore()
      }
    } catch (error) {
      console.error('Error generating test data:', error)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="text-lg">Loading PULSE score...</div>
      </div>
    )
  }

  if (!score) {
    return (
      <div className="text-center p-8 space-y-4">
        <h2 className="text-2xl font-bold text-gray-900">No PULSE Score Yet</h2>
        <p className="text-gray-600">
          Complete some activities to generate your first PULSE score, or generate test data to see how it works.
        </p>
        <div className="space-x-4">
          <button
            onClick={generateTestData}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
          >
            Generate Test Data
          </button>
          <button
            onClick={calculateNewScore}
            disabled={calculating}
            className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 disabled:opacity-50"
          >
            {calculating ? 'Calculating...' : 'Calculate Score'}
          </button>
        </div>
      </div>
    )
  }

  const getScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-600'
    if (score >= 60) return 'text-yellow-600'
    return 'text-red-600'
  }

  const getPillarColor = (score: number) => {
    if (score >= 16) return 'bg-green-100 text-green-800'
    if (score >= 12) return 'bg-yellow-100 text-yellow-800'
    return 'bg-red-100 text-red-800'
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">PULSE Intelligence</h1>
          <p className="text-gray-600">Your business health score</p>
        </div>
        <button
          onClick={calculateNewScore}
          disabled={calculating}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          {calculating ? 'Recalculating...' : 'Recalculate Score'}
        </button>
      </div>

      {/* Main Score Card */}
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-200">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Overall PULSE Score</h2>
            <p className="text-gray-600">Last updated: {new Date(score.calculated_at).toLocaleDateString()}</p>
          </div>
          <div className="text-right">
            <div className={`text-5xl font-bold ${getScoreColor(score.overall_score)}`}>
              {score.overall_score}
            </div>
            <div className="text-sm text-gray-600 capitalize">
              {score.performance_tier} Performance • Top {score.peer_percentile}%
            </div>
          </div>
        </div>

        {/* Predictive Score */}
        <div className="mt-4 p-4 bg-blue-50 rounded-lg">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-semibold text-blue-900">7-Day Forecast</h3>
              <p className="text-blue-700">
                Trend: <span className="capitalize">{score.trend_direction}</span>
              </p>
            </div>
            <div className="text-right">
              <div className="text-2xl font-bold text-blue-900">
                {score.predictive_score}
              </div>
              <div className="text-sm text-blue-700">Predicted Score</div>
            </div>
          </div>
        </div>
      </div>

      {/* Pillar Scores */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
        {[
          { name: 'Planning', score: score.planning_score, key: 'planning' },
          { name: 'Urgency', score: score.urgency_score, key: 'urgency' },
          { name: 'Lead Engagement', score: score.lead_engagement_score, key: 'lead_engagement' },
          { name: 'Systems', score: score.systems_score, key: 'systems' },
          { name: 'Execution', score: score.execution_score, key: 'execution' }
        ].map((pillar) => (
          <div key={pillar.key} className="bg-white rounded-xl p-4 shadow-sm border border-gray-200 text-center">
            <div className={`text-xs font-semibold px-2 py-1 rounded-full ${getPillarColor(pillar.score)}`}>
              {pillar.name}
            </div>
            <div className="text-2xl font-bold text-gray-900 mt-2">
              {pillar.score}
            </div>
            <div className="text-xs text-gray-600 mt-1">
              {pillar.key === score.strongest_pillar && '🏆 Strongest'}
              {pillar.key === score.weakest_pillar && '🎯 Improve'}
            </div>
          </div>
        ))}
      </div>

      {/* Interventions */}
      {interventions.length > 0 && (
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-200">
          <h3 className="text-xl font-bold text-gray-900 mb-4">AI Coaching Recommendations</h3>
          <div className="space-y-4">
            {interventions.map((intervention, index) => (
              <div key={index} className="border-l-4 border-yellow-500 pl-4 py-2">
                <div className="flex items-center justify-between">
                  <h4 className="font-semibold text-gray-900 capitalize">
                    {intervention.pillar_affected.replace('_', ' ')} • {intervention.severity} Priority
                  </h4>
                  <span className="text-sm text-gray-500 capitalize">
                    {intervention.trigger_type.replace('_', ' ')}
                  </span>
                </div>
                <p className="text-gray-700 mt-1">{intervention.recommendation}</p>
                <ul className="mt-2 space-y-1">
                  {intervention.action_steps.map((step, stepIndex) => (
                    <li key={stepIndex} className="text-sm text-gray-600 flex items-center">
                      <span className="w-2 h-2 bg-gray-400 rounded-full mr-2"></span>
                      {step}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
