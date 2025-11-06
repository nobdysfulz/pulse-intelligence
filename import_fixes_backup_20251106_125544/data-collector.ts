// Enhanced PULSE Data Collection Service

import { supabase } from '../supabase'

export interface ActivityMetrics {
  userId: string
  date: Date
  tasksCompleted: number
  tasksOverdue: number
  highPriorityCompleted: number
  goalsActive: number
  goalsOnTrack: number
  contactsAdded: number
  appointmentsSet: number
  contentGenerated: number
  systemsUsed: number
  consistencyStreak: number
}

export class PulseDataCollector {
  
  // Collect all metrics for a user
  async collectUserMetrics(userId: string): Promise<ActivityMetrics> {
    const [
      tasksCompleted,
      tasksOverdue,
      highPriorityCompleted,
      goalsData,
      contactsAdded,
      appointmentsSet,
      contentGenerated,
      systemsUsed,
      consistencyStreak
    ] = await Promise.all([
      this.getTasksCompletedToday(userId),
      this.getOverdueTasks(userId),
      this.getHighPriorityCompleted(userId),
      this.getGoalsData(userId),
      this.getContactsAdded(userId),
      this.getAppointmentsSet(userId),
      this.getContentGenerated(userId),
      this.getSystemsUsed(userId),
      this.getConsistencyStreak(userId)
    ])

    return {
      userId,
      date: new Date(),
      tasksCompleted,
      tasksOverdue,
      highPriorityCompleted,
      goalsActive: goalsData.active,
      goalsOnTrack: goalsData.onTrack,
      contactsAdded,
      appointmentsSet,
      contentGenerated,
      systemsUsed,
      consistencyStreak
    }
  }

  private async getTasksCompletedToday(userId: string): Promise<number> {
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    
    const { data, error } = await supabase
      .from('tasks')
      .select('id')
      .eq('user_id', userId)
      .gte('completed_at', today.toISOString())
      .not('completed_at', 'is', null)

    if (error) {
      console.error('Error fetching completed tasks:', error)
      return 0
    }

    return data?.length || 0
  }

  private async getOverdueTasks(userId: string): Promise<number> {
    const today = new Date().toISOString().split('T')[0]
    
    const { data, error } = await supabase
      .from('tasks')
      .select('id')
      .eq('user_id', userId)
      .lt('due_date', today)
      .is('completed_at', null)

    if (error) {
      console.error('Error fetching overdue tasks:', error)
      return 0
    }

    return data?.length || 0
  }

  private async getHighPriorityCompleted(userId: string): Promise<number> {
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    
    const { data, error } = await supabase
      .from('tasks')
      .select('id')
      .eq('user_id', userId)
      .eq('priority', 'high')
      .gte('completed_at', today.toISOString())
      .not('completed_at', 'is', null)

    if (error) {
      console.error('Error fetching high priority tasks:', error)
      return 0
    }

    return data?.length || 0
  }

  private async getGoalsData(userId: string): Promise<{ active: number; onTrack: number }> {
    const { data: activeGoals, error: activeError } = await supabase
      .from('goals')
      .select('id')
      .eq('user_id', userId)
      .eq('is_completed', false)

    if (activeError) {
      console.error('Error fetching active goals:', activeError)
      return { active: 0, onTrack: 0 }
    }

    // For now, assume all active goals are on track
    // In a real implementation, you'd check progress against targets
    const onTrack = activeGoals?.length || 0

    return {
      active: activeGoals?.length || 0,
      onTrack
    }
  }

  private async getContactsAdded(userId: string): Promise<number> {
    // This would integrate with your CRM or contacts system
    // For now, return a mock value
    return Math.floor(Math.random() * 5) // 0-4 contacts
  }

  private async getAppointmentsSet(userId: string): Promise<number> {
    // This would integrate with your calendar system
    // For now, return a mock value
    return Math.floor(Math.random() * 3) // 0-2 appointments
  }

  private async getContentGenerated(userId: string): Promise<number> {
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    
    const { data, error } = await supabase
      .from('generated_content')
      .select('id')
      .eq('user_id', userId)
      .gte('created_at', today.toISOString())

    if (error) {
      console.error('Error fetching generated content:', error)
      return 0
    }

    return data?.length || 0
  }

  private async getSystemsUsed(userId: string): Promise<number> {
    // Count number of integrated systems actively used
    const { data, error } = await supabase
      .from('user_integrations')
      .select('id')
      .eq('user_id', userId)
      .eq('is_connected', true)

    if (error) {
      console.error('Error fetching integrations:', error)
      return 0
    }

    const integrationCount = data?.length || 0
    
    // Base systems count (dashboard, tasks, goals, etc.)
    const baseSystems = 3
    
    return baseSystems + integrationCount
  }

  private async getConsistencyStreak(userId: string): Promise<number> {
    // This would calculate the user's current activity streak
    // For now, return a mock value
    return Math.floor(Math.random() * 14) + 1 // 1-14 day streak
  }

  // Store metrics for historical analysis
  async storeUserMetrics(metrics: ActivityMetrics): Promise<void> {
    const { error } = await supabase
      .from('user_activity_metrics')
      .insert({
        user_id: metrics.userId,
        date: metrics.date.toISOString().split('T')[0],
        tasks_completed: metrics.tasksCompleted,
        tasks_overdue: metrics.tasksOverdue,
        high_priority_completed: metrics.highPriorityCompleted,
        goals_active: metrics.goalsActive,
        goals_on_track: metrics.goalsOnTrack,
        contacts_added: metrics.contactsAdded,
        appointments_set: metrics.appointmentsSet,
        content_generated: metrics.contentGenerated,
        systems_used: metrics.systemsUsed,
        consistency_streak: metrics.consistencyStreak
      })

    if (error) {
      console.error('Error storing user metrics:', error)
    }
  }
}
