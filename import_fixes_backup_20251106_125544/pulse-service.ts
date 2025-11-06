// Enhanced PULSE Service Orchestrator

import { EnhancedPulseEngine } from './scoring-engine'
import { PulseDataCollector } from './data-collector'
import { supabase } from '../supabase'

export class PulseIntelligenceService {
  private pulseEngine: EnhancedPulseEngine
  private dataCollector: PulseDataCollector

  constructor() {
    this.pulseEngine = new EnhancedPulseEngine()
    this.dataCollector = new PulseDataCollector()
  }

  // Main method to calculate and store enhanced PULSE score
  async calculateAndStorePulseScore(userId: string): Promise<any> {
    try {
      // 1. Collect current metrics
      const metrics = await this.dataCollector.collectUserMetrics(userId)
      
      // 2. Store metrics for historical analysis
      await this.dataCollector.storeUserMetrics(metrics)
      
      // 3. Calculate enhanced PULSE score
      const pulseScore = await this.pulseEngine.calculateEnhancedPulse(userId, metrics)
      
      // 4. Store enhanced score
      await this.storeEnhancedPulseScore(userId, pulseScore)
      
      // 5. Store score history for trends
      await this.storeScoreHistory(userId, pulseScore)
      
      // 6. Generate and store interventions if needed
      if (pulseScore.interventions.length > 0) {
        await this.storeInterventions(userId, pulseScore.interventions)
      }
      
      return pulseScore
      
    } catch (error) {
      console.error('Error calculating PULSE score:', error)
      throw error
    }
  }

  private async storeEnhancedPulseScore(userId: string, score: any): Promise<void> {
    const { error } = await supabase
      .from('enhanced_pulse_scores')
      .insert({
        user_id: userId,
        overall_score: score.overall,
        planning_score: score.planning,
        urgency_score: score.urgency,
        lead_engagement_score: score.leadEngagement,
        systems_score: score.systems,
        execution_score: score.execution,
        trend_direction: score.trendDirection,
        trend_velocity: score.trendVelocity,
        predictive_score: score.predictiveScore,
        confidence_interval: score.confidenceInterval,
        strongest_pillar: score.strongestPillar,
        weakest_pillar: score.weakestPillar,
        improvement_priority: score.improvementPriority,
        peer_percentile: score.peerPercentile,
        performance_tier: score.performanceTier
      })

    if (error) {
      console.error('Error storing enhanced pulse score:', error)
    }
  }

  private async storeScoreHistory(userId: string, score: any): Promise<void> {
    const scoreTypes = [
      { type: 'overall', value: score.overall },
      { type: 'planning', value: score.planning },
      { type: 'urgency', value: score.urgency },
      { type: 'lead_engagement', value: score.leadEngagement },
      { type: 'systems', value: score.systems },
      { type: 'execution', value: score.execution }
    ]

    for (const scoreType of scoreTypes) {
      const { error } = await supabase
        .from('pulse_score_history')
        .insert({
          user_id: userId,
          score_type: scoreType.type,
          score_value: scoreType.value
        })

      if (error) {
        console.error(`Error storing ${scoreType.type} score history:`, error)
      }
    }
  }

  private async storeInterventions(userId: string, interventions: any[]): Promise<void> {
    for (const intervention of interventions) {
      const { error } = await supabase
        .from('pulse_interventions')
        .insert({
          user_id: userId,
          trigger_type: intervention.triggerType,
          pillar_affected: intervention.pillarAffected,
          severity: intervention.severity,
          recommendation: intervention.recommendation,
          action_steps: intervention.actionSteps
        })

      if (error) {
        console.error('Error storing intervention:', error)
      }
    }
  }

  // Get latest PULSE score for a user
  async getLatestPulseScore(userId: string): Promise<any> {
    const { data, error } = await supabase
      .from('enhanced_pulse_scores')
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

  // Get PULSE score history for trend analysis
  async getPulseScoreHistory(userId: string, days: number = 30): Promise<any[]> {
    const cutoffDate = new Date()
    cutoffDate.setDate(cutoffDate.getDate() - days)

    const { data, error } = await supabase
      .from('pulse_score_history')
      .select('*')
      .eq('user_id', userId)
      .gte('calculated_at', cutoffDate.toISOString())
      .order('calculated_at', { ascending: true })

    if (error) {
      console.error('Error fetching pulse score history:', error)
      return []
    }

    return data || []
  }

  // Get active interventions for a user
  async getActiveInterventions(userId: string): Promise<any[]> {
    const { data, error } = await supabase
      .from('pulse_interventions')
      .select('*')
      .eq('user_id', userId)
      .eq('is_completed', false)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching active interventions:', error)
      return []
    }

    return data || []
  }
}
