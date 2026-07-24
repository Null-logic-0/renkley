class OnboardingSetupJob < ApplicationJob
  queue_as :default

  def perform(organization)
    OnboardingTask.seed_for!(organization)

    OnboardingTask::STAGES.each do |stage|
      task = organization.onboarding_tasks.find_by!(key: stage[:key])

      task.start!
      broadcast_task(task)

      run_stage(stage[:key], organization)

      task.finish!
      broadcast_task(task)
    end

    organization.update!(onboarding_status: :completed)
    broadcast_setup_status(organization)
  rescue => e
    Rails.logger.error("[OnboardingSetupJob] org=#{organization.id} failed: #{e.message}")
    raise
  end

  private

  def run_stage(key, organization)
    case key
    when "fetch_profile"         then sleep 0.5
    when "query_platforms"       then AiPlatform.ordered.each { |_p| sleep 0.2 }
    when "benchmark_competitors" then sleep 0.5
    when "build_dashboard"       then sleep 0.3
    end
  end

  def broadcast_task(task)
    Turbo::StreamsChannel.broadcast_replace_to(
      "organization_#{task.organization_id}_onboarding",
      target: "onboarding_task_#{task.id}",
      partial: "onboarding_tasks/task",
      locals: { task: task }
    )
  end

  def broadcast_setup_status(organization)
    Turbo::StreamsChannel.broadcast_replace_to(
      "organization_#{organization.id}_onboarding",
      target: "onboarding_setup_status",
      partial: "onboarding/setup_status",
      locals: { organization: organization }
    )
  end
end
