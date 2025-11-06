// Enhanced PULSE Scoring Engine with Predictive Analytics

export interface PulseMetrics {
  // Core Activities
  tasksCompleted: number;
  tasksOverdue: number;
  highPriorityCompleted: number;
  goalsActive: number;
  goalsOnTrack: number;
  contactsAdded: number;
  appointmentsSet: number;
  contentGenerated: number;
  systemsUsed: number;
  
  // Behavioral Metrics
  consistencyStreak: number;
  activityVolume: number;
  efficiencyRatio: number;
  engagementLevel: number;
}

export interface EnhancedPulseScore {
  // Core Scores
  overall: number;
  planning: number;
  urgency: number;
  leadEngagement: number;
  systems: number;
  execution: number;
  
  // Enhanced Intelligence
  trendDirection: 'improving' | 'stable' | 'declining';
  trendVelocity: number;
  predictiveScore: number;
  confidenceInterval: number;
  
  // Insights
  strongestPillar: string;
  weakestPillar: string;
  improvementPriority: string;
  
  // Benchmarking
  peerPercentile: number;
  performanceTier: 'elite' | 'high' | 'medium' | 'low';
  
  // Coaching
  interventions: PulseIntervention[];
  recommendations: string[];
}

export interface PulseIntervention {
  triggerType: 'score_drop' | 'stagnation' | 'pattern' | 'opportunity';
  pillarAffected: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  recommendation: string;
  actionSteps: string[];
}

export class EnhancedPulseEngine {
  
  // Calculate enhanced PULSE score with predictive analytics
  async calculateEnhancedPulse(userId: string, metrics: PulseMetrics): Promise<EnhancedPulseScore> {
    // Calculate core pillar scores
    const planningScore = this.calculatePlanningScore(metrics);
    const urgencyScore = this.calculateUrgencyScore(metrics);
    const leadEngagementScore = this.calculateLeadEngagementScore(metrics);
    const systemsScore = this.calculateSystemsScore(metrics);
    const executionScore = this.calculateExecutionScore(metrics);
    
    const overallScore = planningScore + urgencyScore + leadEngagementScore + systemsScore + executionScore;
    
    // Calculate enhanced metrics
    const trendAnalysis = await this.analyzeTrends(userId, {
      planning: planningScore,
      urgency: urgencyScore,
      leadEngagement: leadEngagementScore,
      systems: systemsScore,
      execution: executionScore
    });
    
    const predictiveScore = this.calculatePredictiveScore(overallScore, trendAnalysis);
    const benchmarking = await this.calculateBenchmarking(userId, overallScore);
    const interventions = await this.generateInterventions(userId, {
      planning: planningScore,
      urgency: urgencyScore,
      leadEngagement: leadEngagementScore,
      systems: systemsScore,
      execution: executionScore
    }, trendAnalysis);
    
    const insights = this.generateInsights({
      planning: planningScore,
      urgency: urgencyScore,
      leadEngagement: leadEngagementScore,
      systems: systemsScore,
      execution: executionScore
    });
    
    return {
      overall: overallScore,
      planning: planningScore,
      urgency: urgencyScore,
      leadEngagement: leadEngagementScore,
      systems: systemsScore,
      execution: executionScore,
      ...trendAnalysis,
      predictiveScore,
      ...benchmarking,
      ...insights,
      interventions,
      recommendations: this.generateRecommendations(interventions)
    };
  }
  
  private calculatePlanningScore(metrics: PulseMetrics): number {
    let score = 0;
    
    // Business plan existence and activity (up to 6 points)
    if (metrics.goalsActive > 0) score += 4;
    if (metrics.goalsActive >= 3) score += 2;
    
    // Goal progress tracking (up to 6 points)
    if (metrics.goalsOnTrack > 0) score += 3;
    const onTrackRatio = metrics.goalsActive > 0 ? metrics.goalsOnTrack / metrics.goalsActive : 0;
    if (onTrackRatio >= 0.7) score += 3;
    
    // Strategic activity (up to 8 points)
    if (metrics.contentGenerated > 0) score += 2;
    if (metrics.systemsUsed >= 3) score += 3;
    if (metrics.consistencyStreak >= 7) score += 3;
    
    return Math.min(20, score);
  }
  
  private calculateUrgencyScore(metrics: PulseMetrics): number {
    let score = 0;
    
    // Task completion rate (up to 8 points)
    const totalTasks = metrics.tasksCompleted + metrics.tasksOverdue;
    if (totalTasks > 0) {
      const completionRate = metrics.tasksCompleted / totalTasks;
      score += Math.floor(completionRate * 8);
    }
    
    // High priority task focus (up to 6 points)
    if (metrics.highPriorityCompleted > 0) {
      score += Math.min(6, metrics.highPriorityCompleted * 2);
    }
    
    // Overdue task management (up to 6 points)
    if (metrics.tasksOverdue === 0) score += 6;
    else if (metrics.tasksOverdue <= 2) score += 3;
    
    return Math.min(20, score);
  }
  
  private calculateLeadEngagementScore(metrics: PulseMetrics): number {
    let score = 0;
    
    // Contact growth (up to 7 points)
    if (metrics.contactsAdded >= 10) score += 7;
    else if (metrics.contactsAdded >= 5) score += 5;
    else if (metrics.contactsAdded >= 1) score += 3;
    
    // Appointment setting (up to 7 points)
    if (metrics.appointmentsSet >= 3) score += 7;
    else if (metrics.appointmentsSet >= 1) score += 5;
    else if (metrics.appointmentsSet >= 0) score += 2;
    
    // Engagement consistency (up to 6 points)
    if (metrics.consistencyStreak >= 14) score += 6;
    else if (metrics.consistencyStreak >= 7) score += 4;
    else if (metrics.consistencyStreak >= 3) score += 2;
    
    return Math.min(20, score);
  }
  
  private calculateSystemsScore(metrics: PulseMetrics): number {
    let score = 0;
    
    // Platform feature usage (up to 8 points)
    score += Math.min(8, metrics.systemsUsed * 2);
    
    // Content generation (up to 6 points)
    if (metrics.contentGenerated >= 5) score += 6;
    else if (metrics.contentGenerated >= 2) score += 4;
    else if (metrics.contentGenerated >= 1) score += 2;
    
    // Integration usage (up to 6 points)
    if (metrics.systemsUsed >= 4) score += 6;
    else if (metrics.systemsUsed >= 2) score += 4;
    else if (metrics.systemsUsed >= 1) score += 2;
    
    return Math.min(20, score);
  }
  
  private calculateExecutionScore(metrics: PulseMetrics): number {
    let score = 0;
    
    // Overall activity volume (up to 7 points)
    const totalActivities = metrics.tasksCompleted + metrics.contactsAdded + metrics.appointmentsSet;
    if (totalActivities >= 15) score += 7;
    else if (totalActivities >= 8) score += 5;
    else if (totalActivities >= 3) score += 3;
    
    // Goal progress (up to 7 points)
    if (metrics.goalsOnTrack > 0) {
      const progressRatio = metrics.goalsActive > 0 ? metrics.goalsOnTrack / metrics.goalsActive : 0;
      score += Math.floor(progressRatio * 7);
    }
    
    // Consistency (up to 6 points)
    if (metrics.consistencyStreak >= 21) score += 6;
    else if (metrics.consistencyStreak >= 14) score += 4;
    else if (metrics.consistencyStreak >= 7) score += 2;
    
    return Math.min(20, score);
  }
  
  private async analyzeTrends(userId: string, currentScores: any) {
    // This would query historical data from pulse_score_history
    // For now, return mock trend analysis
    return {
      trendDirection: 'improving' as const,
      trendVelocity: 2.5,
      confidenceInterval: 0.85
    };
  }
  
  private calculatePredictiveScore(currentScore: number, trendAnalysis: any): number {
    const predictedChange = trendAnalysis.trendVelocity * 7; // 7-day projection
    return Math.min(100, Math.max(0, currentScore + predictedChange));
  }
  
  private async calculateBenchmarking(userId: string, score: number) {
    // This would compare against peer data
    // For now, return mock benchmarking
    let percentile = 50;
    let tier: 'elite' | 'high' | 'medium' | 'low' = 'medium';
    
    if (score >= 85) {
      percentile = 90;
      tier = 'elite';
    } else if (score >= 70) {
      percentile = 75;
      tier = 'high';
    } else if (score >= 50) {
      percentile = 50;
      tier = 'medium';
    } else {
      percentile = 25;
      tier = 'low';
    }
    
    return { peerPercentile: percentile, performanceTier: tier };
  }
  
  private async generateInterventions(userId: string, scores: any, trends: any): Promise<PulseIntervention[]> {
    const interventions: PulseIntervention[] = [];
    
    // Identify weakest pillar
    const pillarScores = [
      { pillar: 'planning', score: scores.planning },
      { pillar: 'urgency', score: scores.urgency },
      { pillar: 'lead_engagement', score: scores.leadEngagement },
      { pillar: 'systems', score: scores.systems },
      { pillar: 'execution', score: scores.execution }
    ];
    
    const weakest = pillarScores.reduce((min, pillar) => pillar.score < min.score ? pillar : min);
    
    if (weakest.score < 10) {
      interventions.push({
        triggerType: 'score_drop',
        pillarAffected: weakest.pillar,
        severity: 'high',
        recommendation: `Your ${weakest.pillar.replace('_', ' ')} score needs immediate attention`,
        actionSteps: this.getActionStepsForPillar(weakest.pillar)
      });
    }
    
    // Add trend-based interventions
    if (trends.trendDirection === 'declining' && trends.trendVelocity < -1) {
      interventions.push({
        triggerType: 'stagnation',
        pillarAffected: 'overall',
        severity: 'medium',
        recommendation: 'Your performance trend is declining. Let\'s identify the cause.',
        actionSteps: [
          'Review recent task completion rates',
          'Check goal progress alignment',
          'Analyze time allocation patterns'
        ]
      });
    }
    
    return interventions;
  }
  
  private generateInsights(scores: any) {
    const pillars = [
      { name: 'planning', score: scores.planning },
      { name: 'urgency', score: scores.urgency },
      { name: 'lead_engagement', score: scores.leadEngagement },
      { name: 'systems', score: scores.systems },
      { name: 'execution', score: scores.execution }
    ];
    
    const strongest = pillars.reduce((max, pillar) => pillar.score > max.score ? pillar : max);
    const weakest = pillars.reduce((min, pillar) => pillar.score < min.score ? pillar : min);
    
    return {
      strongestPillar: strongest.name,
      weakestPillar: weakest.name,
      improvementPriority: weakest.name
    };
  }
  
  private generateRecommendations(interventions: PulseIntervention[]): string[] {
    return interventions.map(intervention => intervention.recommendation);
  }
  
  private getActionStepsForPillar(pillar: string): string[] {
    const actionSteps: { [key: string]: string[] } = {
      planning: [
        'Create or update your 12-month business plan',
        'Set 3 specific goals for this week',
        'Schedule 30 minutes for strategic planning'
      ],
      urgency: [
        'Complete all overdue tasks today',
        'Identify and tackle 2 high-priority items',
        'Set specific deadlines for open tasks'
      ],
      lead_engagement: [
        'Add 5 new contacts to your database',
        'Schedule 2 appointments for this week',
        'Follow up with 3 past leads'
      ],
      systems: [
        'Explore one new platform feature',
        'Generate content using the Content Studio',
        'Connect an integration (CRM, calendar, etc.)'
      ],
      execution: [
        'Complete your daily action plan',
        'Review goal progress and adjust as needed',
        'Maintain your activity streak'
      ]
    };
    
    return actionSteps[pillar] || ['Focus on consistent daily activity'];
  }
}
