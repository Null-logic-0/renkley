module OnboardingHelper
  AVATAR_COLOR_COUNT = 5

  # Cycles a fixed 5-color palette by list position — deterministic, not stored.
  def onboarding_avatar_class(index)
    "is-c#{index % AVATAR_COLOR_COUNT}"
  end

  def onboarding_step_counter(organization)
    return "Finishing up" if organization.onboarding_step_name == "setup"
    "Step #{organization.onboarding_step} of #{Organization::ONBOARDING_STEPS.length}"
  end

  def onboarding_progress_percent(organization)
    (organization.onboarding_step.to_f / Organization::ONBOARDING_STEPS.length * 100).round
  end

  def onboarding_task_icon(task)
    case task.status
    when "done"   then shared_icon(:check, size: 13, stroke_width: 2.4)
    when "failed" then shared_icon(:x, size: 13, stroke_width: 2.4)
    when "in_progress" then shared_icon(:loader, size: 13, stroke_width: 2)
    else shared_icon(:circle, size: 13, stroke_width: 1.5)
    end
  end

  def onboarding_row_class(task)
    "rk-onb-check-row is-#{task.status}"
  end
end
