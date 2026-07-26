module SidebarHelper
  # href: "#" marks a destination that doesn't have a page yet — matches the
  # source design, which was itself a client-side-only prototype for these.
  NAV_SECTIONS = [
    { title: "Monitor", items: [
      { id: "overview", label: "Overview", icon: :grid, href: "/overview" },
      { id: "visibility", label: "AI Visibility", icon: :eye, href: "#" },
      { id: "competitors", label: "Competitors", icon: :trophy, href: "#" },
      { id: "prompts", label: "Prompts", icon: :message, href: "#", badge: true },
      { id: "mentions", label: "Mentions", icon: :at_sign, href: "#" }
    ] },
    { title: "Optimize", items: [
      { id: "keywords", label: "Keywords", icon: :hash, href: "#" },
      { id: "audit", label: "SEO Audit", icon: :clipboard_check, href: "#" }
    ] },
    { title: "Insights", items: [
      { id: "reports", label: "Reports", icon: :file_text, href: "/reports" },
      { id: "analytics", label: "Analytics", icon: :line_chart, href: "#" }
    ] }
  ].freeze

  def active_nav_item?(item)
    item[:href].present? && item[:href] != "#" && current_page?(item[:href])
  end

  def prompts_badge_count
    Current.organization&.prompts&.count || 0
  end
end
