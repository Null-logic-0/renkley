module SidebarHelper
  NAV_SECTIONS = [
    { title: "Monitor", items: [
      { id: "overview", label: "Overview", icon: :grid, href: "/overview" },
      { id: "visibility", label: "AI Visibility", icon: :eye, href: "/visibility" },
      { id: "competitors", label: "Competitors", icon: :trophy, href: "/competitors" },
      { id: "prompts", label: "Prompts", icon: :message, href: "/prompts", badge: true },
      { id: "mentions", label: "Mentions", icon: :at_sign, href: "/mentions" }
    ] },
    { title: "Optimize", items: [
      { id: "keywords", label: "Keywords", icon: :hash, href: "/keywords" },
      { id: "audit", label: "SEO Audit", icon: :clipboard_check, href: "/audit" }
    ] },
    { title: "Insights", items: [
      { id: "reports", label: "Reports", icon: :file_text, href: "/reports" },
      { id: "analytics", label: "Analytics", icon: :line_chart, href: "/analytics" }
    ] }
  ].freeze

  def active_nav_item?(item)
    item[:href].present? && item[:href] != "#" && current_page?(item[:href])
  end

  def prompts_badge_count
    Current.organization&.prompts&.count || 0
  end
end
