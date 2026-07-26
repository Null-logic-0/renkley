class OverviewPresenter
  include ActionView::Helpers::NumberHelper

  PLATFORM_COLORS = {
    "chatgpt" => "#0e9c8e", "claude" => "#5b41f0", "gemini" => "#c07d0a"
  }.freeze

  SCAN_HISTORY_LENGTH = 8
  SCAN_CADENCE = 24.hours

  attr_reader :organization

  def initialize(organization)
    @organization = organization
    @scans = organization.scans.completed_ordered.last(SCAN_HISTORY_LENGTH)
    @latest_scan = @scans.last
    @own_company = organization.companies.owned.first
  end

  def latest_scan = @latest_scan
  def scanned? = @latest_scan.present?
  def scanning? = organization.scans.where(status: [ :pending, :running ]).exists?

  def scan_status_label
    return "Running your AI visibility scan…" if scanning?
    return "No scans yet — run your first AI visibility scan" unless scanned?

    elapsed = Time.current - @latest_scan.finished_at
    next_due = [ (SCAN_CADENCE - elapsed), 0 ].max
    "Last scan #{time_ago_words(elapsed)} ago · #{next_due.zero? ? "next scan due" : "next in #{time_ago_words(next_due)}"}"
  end

  def score = @latest_scan&.overall_score || 0
  def score_previous = previous_scan&.overall_score
  def score_delta_pct = delta_pct(score, score_previous)
  def score_history = @scans.map(&:overall_score)
  def score_grade = grade_for(score)

  def hero_metrics
    [
      { label: "Ranking position", value: "##{@latest_scan&.ranking_position || "—"}", unit: "of #{competitor_count}",
        history: @scans.map(&:ranking_position), delta: delta_pct(@latest_scan&.ranking_position, previous_scan&.ranking_position, invert: true),
        sub: "Tracked across #{organization.companies.competitor.count} competitors" },
      { label: "AI mentions", value: number_with_delimiter(@latest_scan&.mentions_count || 0), unit: "/scan",
        history: @scans.map(&:mentions_count), delta: delta_pct(@latest_scan&.mentions_count, previous_scan&.mentions_count),
        sub: "Across #{platform_count} AI #{"platform".pluralize(platform_count)}" },
      { label: "Citation share", value: (@latest_scan&.citation_share_pct || 0).to_i, unit: "%",
        history: @scans.map { |s| s.citation_share_pct.to_f }, delta: delta_pct(@latest_scan&.citation_share_pct, previous_scan&.citation_share_pct),
        sub: "Share of sources cited" }
    ]
  end

  def integrated_platforms
    @integrated_platforms ||= AiPlatform.integrated.ordered.to_a
  end

  def platform_count = integrated_platforms.size

  def platforms
    return [] unless scanned?

    snapshots = @latest_scan.platform_snapshots.own.includes(:ai_platform).index_by(&:ai_platform_id)
    integrated_platforms.map do |platform|
      snap = snapshots[platform.id]
      next unless snap

      history = platform_history(platform.id)
      previous = history[-2]
      { name: platform.name, color: PLATFORM_COLORS.fetch(platform.key, "#7d7979"), vis: snap.visibility_pct,
        rank: snap.rank_label, mentions: snap.mentions_count, history: history,
        delta: delta_pct(snap.visibility_pct, previous) }
    end.compact
  end

  def competitors
    return [] unless scanned?

    own_snapshot = { score: score, citations_count: citations.sum(&:mentions_count) / [ citations.size, 1 ].max }
    rows = [ { company: @own_company, you: true, snapshot: own_snapshot, history: score_history } ]

    @latest_scan.competitor_snapshots.includes(:company).find_each do |snap|
      rows << { company: snap.company, you: false, snapshot: snap, history: competitor_history(snap.company_id) }
    end

    rows.sort_by { |r| -r[:snapshot][:score].to_i }.map do |row|
      snap = row[:snapshot]
      previous = row[:history][-2]
      {
        company_id: row[:company]&.id, brand: row[:company]&.name || organization.name, you: row[:you],
        score: snap[:score], platform_mentions: platform_mentions_for(row[:company], you: row[:you]),
        cites: snap[:citations_count],
        delta: delta_pct(row[:history].last, previous), history: row[:history],
        note: competitor_note(row[:you], row[:history])
      }
    end
  end

  def leading_rival
    return nil unless scanned?

    top_rival = competitors.find { |c| !c[:you] }
    return nil unless top_rival && top_rival[:score].to_i > score

    lost_prompts = @latest_scan.prompt_results.where(winner_company_id: top_rival[:company_id]).count
    { brand: top_rival[:brand], gap: top_rival[:score] - score, lost_prompts: lost_prompts }
  end

  def prompt_tabs
    all = organization.prompts.ordered.to_a
    latest_results = @latest_scan ? @latest_scan.prompt_results.index_by(&:prompt_id) : {}
    categorized = all.map { |p| [ p, prompt_category(latest_results[p.id]) ] }
    {
      "all" => categorized.size,
      "win" => categorized.count { |_, c| c == "win" },
      "lose" => categorized.count { |_, c| c == "lose" },
      "none" => categorized.count { |_, c| c == "none" }
    }
  end


  def prompts(tab: "all")
    results_by_prompt = @latest_scan ? @latest_scan.prompt_results.includes(:ai_platform, :winner_company, :top_competitor_company).index_by(&:prompt_id) : {}

    rows = organization.prompts.ordered.filter_map do |prompt|
      row = prompt_row(prompt, results_by_prompt[prompt.id])
      row if tab == "all" || tab == row[:category]
    end
    rows.sort_by { |r| { "high" => 0, "medium" => 1, "low" => 2 }.fetch(r[:volume], 3) }
  end


  def prompt_row(prompt, result = :lookup)
    result = @latest_scan&.prompt_results&.find_by(prompt_id: prompt.id) if result == :lookup
    category = prompt_category(result)

    { prompt_id: prompt.id, prompt: prompt.body, you: result&.your_position ? "##{result.your_position}" : "—",
      comp: result&.top_competitor_company&.name || "—", winner: result&.winner_company&.name || "—", category: category,
      platform: result&.ai_platform&.name || "—", volume: prompt.search_volume }
  end

  def citations = organization.citations.ordered
  def recommendations = organization.recommendations.pending.ordered
  def reports = organization.reports.ordered

  def mentions_timeline
    { labels: @scans.map { |s| s.finished_at.strftime("%b") },
      mentions: @scans.map(&:mentions_count),
      citations: @scans.map { |s| ((s.citation_share_pct.to_f / 100) * s.mentions_count).round } }
  end

  def footer_status
    "#{organization.name} · AI visibility scan #{scanned? ? "completed #{time_ago_words(Time.current - @latest_scan.finished_at)} ago" : "not yet run"} · " \
    "tracking #{competitor_count} brands across #{platform_count} AI #{"platform".pluralize(platform_count)}"
  end

  private

  def previous_scan = @scans[-2]
  def competitor_count = organization.companies.competitor.count + 1

  def platform_mentions_for(company, you:)
    scope = you ? @latest_scan.platform_snapshots.own : @latest_scan.platform_snapshots.for_company(company)
    by_platform = scope.includes(:ai_platform).index_by(&:ai_platform_id)
    integrated_platforms.map { |platform| { name: platform.name, value: by_platform[platform.id]&.mentions_count || 0 } }
  end

  def platform_history(ai_platform_id)
    PlatformSnapshot.own.where(scan_id: @scans.map(&:id), ai_platform_id: ai_platform_id)
                     .index_by(&:scan_id).values_at(*@scans.map(&:id)).compact.map(&:visibility_pct)
  end

  def competitor_history(company_id)
    CompetitorSnapshot.where(scan_id: @scans.map(&:id), company_id: company_id)
                       .index_by(&:scan_id).values_at(*@scans.map(&:id)).compact.map(&:score)
  end

  def prompt_category(result)
    return "none" unless result
    return "none" if result.your_position.nil?

    result.you_won? ? "win" : "lose"
  end

  def competitor_note(you, history)
    return "Your fastest-growing brand this quarter." if you && trending_up?(history)
    return "Holding steady across tracked platforms." if you

    trending_up?(history) ? "Gaining ground across tracked prompts." : "Losing ground against the field."
  end

  def trending_up?(history)
    return true if history.size < 2
    history.last >= history.first
  end

  def delta_pct(current, previous, invert: false)
    return nil if current.nil? || previous.nil? || previous.zero?

    pct = (((current - previous) / previous.to_f) * 100).round
    pct = -pct if invert
    pct
  end

  def grade_for(score)
    case score
    when 90.. then "A"
    when 80...90 then "A-"
    when 70...80 then "B+"
    when 60...70 then "B"
    when 50...60 then "C"
    else "D"
    end
  end

  def time_ago_words(seconds)
    seconds = seconds.to_i
    return "#{seconds / 86400}d" if seconds >= 86400
    return "#{[ seconds / 3600, 1 ].max}h" if seconds >= 3600
    "#{[ seconds / 60, 1 ].max}m"
  end
end
