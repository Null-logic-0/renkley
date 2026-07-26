module RecommendationsHelper
  PRIORITY_MODIFIERS = { "high" => "is-high", "medium" => "is-medium", "low" => "is-low" }.freeze
  EFFORT_MODIFIERS   = { "easy" => "is-easy", "medium_effort" => "is-medium_effort", "hard" => "is-hard" }.freeze

  def recommendation_priority_bar_class(recommendation)
    class_names("rk-ov-rec-priority-bar", PRIORITY_MODIFIERS.fetch(recommendation.priority))
  end

  def recommendation_priority_tag_class(recommendation)
    class_names("rk-ov-rec-priority-tag", PRIORITY_MODIFIERS.fetch(recommendation.priority))
  end

  def recommendation_effort_dot_class(recommendation)
    class_names("rk-ov-rec-effort-dot", EFFORT_MODIFIERS.fetch(recommendation.effort))
  end

  def recommendation_impact_cell_class(index, score_out_of_ten)
    class_names("filled" => index < score_out_of_ten)
  end


  def effort_label(effort)
    effort.to_s.sub(/_effort\z/, "").humanize
  end
end
