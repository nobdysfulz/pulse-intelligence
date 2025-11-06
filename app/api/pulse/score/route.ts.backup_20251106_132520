import { NextRequest, NextResponse } from 'next/server'
import { currentUser } from '@clerk/nextjs/server'
import { PulseIntelligenceService } from '../../../../lib/pulse-intelligence/pulse-service'

export async function GET(request: NextRequest) {
  try {
    // Get the current user from Clerk
    const user = await currentUser()
    
    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const pulseService = new PulseIntelligenceService()
    
    // Get the latest pulse score (without recalculating)
    const latestScore = await pulseService.getLatestPulseScore(user.id)
    
    if (!latestScore) {
      return NextResponse.json(
        { error: 'No pulse score found. Complete some activities to generate your first score.' },
        { status: 404 }
      )
    }

    // Get active interventions
    const interventions = await pulseService.getActiveInterventions(user.id)
    
    // Get score history for trends
    const scoreHistory = await pulseService.getPulseScoreHistory(user.id, 7)

    return NextResponse.json({
      success: true,
      data: {
        score: latestScore,
        interventions,
        history: scoreHistory,
        lastUpdated: latestScore.calculated_at
      }
    })

  } catch (error) {
    console.error('Error fetching pulse score:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    // Get the current user from Clerk
    const user = await currentUser()
    
    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const pulseService = new PulseIntelligenceService()
    
    // Calculate a new pulse score
    const newScore = await pulseService.calculateAndStorePulseScore(user.id)
    
    return NextResponse.json({
      success: true,
      data: {
        score: newScore,
        message: 'PULSE score calculated successfully'
      }
    })

  } catch (error) {
    console.error('Error calculating pulse score:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
