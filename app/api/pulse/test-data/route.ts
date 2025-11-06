import { NextRequest, NextResponse } from 'next/server'
import { currentUser } from '@clerk/nextjs/server'
import { supabase } from "@/lib/supabase"

export async function POST(request: NextRequest) {
  try {
    const user = await currentUser()
    
    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    // Generate sample tasks for the user
    await generateSampleTasks(user.id)
    
    // Generate sample goals
    await generateSampleGoals(user.id)
    
    // Generate sample content
    await generateSampleContent(user.id)

    return NextResponse.json({
      success: true,
      message: 'Test data generated successfully',
      data: {
        tasks: 5,
        goals: 3,
        content: 2
      }
    })

  } catch (error) {
    console.error('Error generating test data:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

async function generateSampleTasks(userId: string) {
  const sampleTasks = [
    {
      title: 'Follow up with 3 leads',
      description: 'Contact leads from open house',
      priority: 'high',
      due_date: new Date().toISOString()
    },
    {
      title: 'Update business plan',
      description: 'Review and adjust Q1 goals',
      priority: 'medium',
      due_date: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString()
    },
    {
      title: 'Create social media content',
      description: 'Post about new listing',
      priority: 'medium',
      due_date: new Date().toISOString()
    },
    {
      title: 'Network with local agents',
      description: 'Attend broker open house',
      priority: 'low',
      due_date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
    },
    {
      title: 'Complete daily training',
      description: 'Role-play objection handling',
      priority: 'high',
      due_date: new Date().toISOString()
    }
  ]

  // Insert sample actions (using daily_actions table)
  for (const task of sampleTasks) {
    const { error } = await supabase
      .from('daily_actions')
      .insert({
        user_id: userId,
        title: task.title,
        description: task.description,
        priority: task.priority,
        due_date: task.due_date,
        category: 'general',
        status: 'pending'
      })

    if (error) {
      console.error('Error creating sample action:', error)
    }
  }

  // Mark some actions as completed
  const { data: actions } = await supabase
    .from('daily_actions')
    .select('id')
    .eq('user_id', userId)
    .limit(3)

  if (actions) {
    for (const action of actions) {
      await supabase
        .from('daily_actions')
        .update({ status: 'completed' })
        .eq('id', action.id)
    }
  }
}

async function generateSampleGoals(userId: string) {
  const sampleGoals = [
    {
      title: 'Achieve $100k GCI',
      description: 'Annual gross commission income target',
      goal_type: 'gci',
      target_value: 100000,
      current_value: 25000,
      unit: 'USD',
      deadline: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
    },
    {
      title: 'Close 12 transactions',
      description: 'Annual transaction target',
      goal_type: 'transactions',
      target_value: 12,
      current_value: 3,
      unit: 'deals',
      deadline: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
    },
    {
      title: 'Add 50 new contacts',
      description: 'Grow contact database',
      goal_type: 'contacts',
      target_value: 50,
      current_value: 15,
      unit: 'contacts',
      deadline: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
    }
  ]

  for (const goal of sampleGoals) {
    const { error } = await supabase
      .from('goals')
      .insert({
        user_id: userId,
        ...goal
      })

    if (error) {
      console.error('Error creating sample goal:', error)
    }
  }
}

async function generateSampleContent(userId: string) {
  const sampleContent = [
    {
      content_type: 'social_post',
      title: 'Market Update Post',
      content: 'Exciting market trends in our area! Contact me for a personalized market analysis.'
    },
    {
      content_type: 'video_script',
      title: 'Property Tour Script',
      content: 'Welcome to this beautiful home featuring...'
    }
  ]

  for (const content of sampleContent) {
    const { error } = await supabase
      .from('generated_content')
      .insert({
        user_id: userId,
        ...content
      })

    if (error) {
      console.error('Error creating sample content:', error)
    }
  }
}
