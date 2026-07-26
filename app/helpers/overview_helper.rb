module OverviewHelper
  # Small "+12%" / "-3%" chip with a trend arrow, used across the score
  # strip, platform cards, competitor table and citations list.
  def delta_chip(value, size: 11)
    return content_tag(:span, "—", class: "rk-delta is-flat") if value.nil?

    icon = shared_icon(value >= 0 ? :trend_up : :trend_down, size: size)
    content_tag(:span, class: "rk-delta #{value >= 0 ? "is-up" : "is-down"}") { safe_join([ icon, "#{value.abs}%" ]) }
  end

  def prompt_winner_class(category) = class_names("rk-ov-prompt-winner", "is-#{category}")
  def volume_dot_class(volume) = class_names("rk-ov-vol-dot", "is-#{volume}")
end
