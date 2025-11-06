import { supabase } from '../supabase'
import { calculatePulseScore } from '../../components/pulse/pulseScoring'

interface PulseScore {
  id: string
  user_id: string
  overall_score: number
  production_score: number
  urgency_score?: number
  pipeline_score: number
  systems_score: number
  activities_score: number
  mindset_score: number
  created_at: string
  date: string
  metrics?: any
}

interface Intervention {
  id?: string
  user_id: string
  intervention_type: string
  severity: string
  message: string
  created_at: string
  is_active: boolean
}

export class PulseIntelligenceService {
  async getLatestPulseScore(userId: string): Promise<PulseScore | null> {
    const { data, error } = await supabase
      .from('pulse_scores')
      .select('*')
      .eq('user_id', userId)
      .order('calculated_at', { ascending: false })
      .limit(1)
      .single()

    if (error) {
      console.error('Error fetching latest pulse score:', error)
      return null
    }

    return data
  }

  async getPulseScoreHistory(userId: string, days: number = 7): Promise<PulseScore[]> {
    const since = new Date()
    since.setDate(since.getDate() - days)

    const { data, error } = await supabase
      .from('pulse_scores')
      .select('*')
      .eq('user_id', userId)
      .gte('calculated_at', since.toISOString())
      .order('calculated_at', { ascending: true })

    if (error) {
      console.error('Error fetching pulse score history:', error)
      return []
    }

    return data || []
  }

  async getActiveInterventions(userId: string): Promise<Intervention[]> {
    const result = await (supabase as any)
      .from('pulse_interventions')
      .select('*')
      .eq('user_id', userId)
      .eq('is_active', true)
      .order('created_at', { ascending: false })

    const { data, error } = result

    if (error) {
      console.error('Error fetching interventions:', error)
      return []
    }

    return (data || []) as Intervention[]
  }

  async calculateAndStorePulseScore(userId: string): Promise<PulseScore> {
    // Fetch user data needed for calculation
    const { data: goals } = await supabase
      .from('goals')
      .select('*')
      .eq('user_id', userId)

    const { data: actions } = await supabase
      .from('daily_actions')
      .select('*')
      .eq('user_id', userId)

    const { data: profile } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single()

    // Calculate the score using existing logic
    const scoreData = calculatePulseScore(
      goals || [],
      actions || [],
      profile,
      0 // contact count - can be enhanced later
    )

    // Store the score in the database
    const pulseScore = {
      user_id: userId,
      overall_score: scoreData.overallPulseScore,
      production_score: scoreData.planningAdherence || 0,
      urgency_score: scoreData.urgencyManagement || 0,
      pipeline_score: scoreData.leadEngagement || 0,
      systems_score: scoreData.systemsUtilization || 0,
      activities_score: scoreData.executionConsistency || 0,
      mindset_score: 0,
      date: new Date().toISOString().split('T')[0],
      metrics: scoreData.diagnostics || {}
    }

    const { data, error } = await (supabase as any)
      .from('pulse_scores')
      .insert(pulseScore)
      .select()
      .single()

    if (error) {
      console.error('Error storing pulse score:', error)
      throw new Error('Failed to store pulse score')
    }

    // Generate interventions if needed
    await this.generateInterventions(userId, scoreData)

    return data
  }

  private async generateInterventions(userId: string, scoreData: any): Promise<void> {
    const interventions: Partial<Intervention>[] = []

    // Check for low scores and generate interventions
    if (scoreData.overallPulseScore < 40) {
      interventions.push({
        user_id: userId,
        intervention_type: 'low_pulse_score',
        severity: 'high',
        message: 'Your PULSE score is below 40. Focus on completing high-priority tasks.',
        created_at: new Date().toISOString(),
        is_active: true
      })
    }

    if (scoreData.urgencyManagement < 10) {
      interventions.push({
        user_id: userId,
        intervention_type: 'urgency_management',
        severity: 'medium',
        message: 'You have overdue tasks. Address them to improve your urgency score.',
        created_at: new Date().toISOString(),
        is_active: true
      })
    }

    if (scoreData.planningAdherence < 10) {
      interventions.push({
        user_id: userId,
        intervention_type: 'planning',
        severity: 'medium',
        message: 'Set more goals to improve your planning score.',
        created_at: new Date().toISOString(),
        is_active: true
      })
    }

    // Deactivate old interventions
    await (supabase as any)
      .from('pulse_interventions')
      .update({ is_active: false })
      .eq('user_id', userId)
      .eq('is_active', true)

    // Insert new interventions
    if (interventions.length > 0) {
      await (supabase as any)
        .from('pulse_interventions')
        .insert(interventions)
    }
  }
}
