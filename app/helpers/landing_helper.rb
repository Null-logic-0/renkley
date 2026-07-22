module LandingHelper
  ICONS = {
    eye: '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>',
    trophy: '<path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M6 3h12v6a6 6 0 0 1-12 0Z"/><path d="M9 21h6"/><path d="M12 15v6"/>',
    message: '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2Z"/>',
    sparkles: '<path d="M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M18 6l-2.5 2.5M6 18l2.5-2.5M18 18l-2.5-2.5"/>',
    trending: '<path d="M3 3v18h18"/><path d="m19 9-5 5-4-4-3 3"/>',
    check: '<path d="M20 6 9 17l-5-5"/>',
    chevron_down: '<path d="m6 9 6 6 6-6"/>',
    menu: '<line x1="4" y1="7" x2="20" y2="7"/><line x1="4" y1="12" x2="20" y2="12"/><line x1="4" y1="17" x2="20" y2="17"/>',
    x: '<path d="M18 6 6 18M6 6l12 12"/>',
    linkedin: '<path d="M16 8a6 6 0 0 1 6 6v6h-4v-6a2 2 0 0 0-4 0v6h-4v-6a6 6 0 0 1 6-6Z"/><rect x="2" y="9" width="4" height="11"/><circle cx="4" cy="4" r="2"/>',
    github: '<path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.5c0-1 .1-1.4-.5-2 2.8-.3 5.5-1.4 5.5-6a4.6 4.6 0 0 0-1.3-3.2 4.2 4.2 0 0 0-.1-3.2s-1.1-.3-3.5 1.3a12 12 0 0 0-6.2 0C6.5 2.3 5.4 2.6 5.4 2.6a4.2 4.2 0 0 0-.1 3.2A4.6 4.6 0 0 0 4 9c0 4.6 2.7 5.7 5.5 6-.6.6-.6 1.2-.5 2V21"/>'
  }.freeze

  # Renders one of ICONS as an inline stroke-style SVG (lucide-style).
  def rk_icon(name, size: 20, stroke_width: 1.75)
    inner = ICONS.fetch(name)
    content_tag(:svg, inner.html_safe,
      viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
      "stroke-width": stroke_width, "stroke-linecap": "round", "stroke-linejoin": "round",
      width: size, height: size, style: "display:block")
  end

  # Small area/line sparkline used in the hero + dashboard preview mockups.
  def rk_mini_area_chart(data, width: 420, height: 150)
    pad = 8
    inner_height = height - (pad * 2)
    n = data.length
    span = (data.max - data.min).nonzero? || 1
    mn = data.min - (span * 0.15)
    mx = data.max + (span * 0.15)
    domain = mx - mn

    x_at = ->(i) { (i.to_f / (n - 1)) * width }
    y_at = ->(v) { pad + inner_height - (((v - mn) / domain) * inner_height) }

    line_d = data.each_with_index.map { |v, i| "#{i.zero? ? 'M' : 'L'}#{x_at.call(i).round(1)} #{y_at.call(v).round(1)}" }.join(" ")
    area_d = "#{line_d} L #{width} #{height} L 0 #{height} Z"
    last_x = x_at.call(n - 1).round(1)
    last_y = y_at.call(data.last).round(1)
    grid_ys = [ 0.25, 0.5, 0.75 ].map { |f| (pad + (inner_height * f)).round(1) }

    content_tag(:svg, class: "rk-chart-svg", height: height, viewBox: "0 0 #{width} #{height}",
      preserveAspectRatio: "none") do
      safe_join(
        grid_ys.map { |gy| tag.line(x1: 0, x2: width, y1: gy, y2: gy, stroke: "var(--rk-line-soft)", "stroke-width": 1, "vector-effect": "non-scaling-stroke") } + [
          tag.path(d: area_d, fill: "var(--rk-accent)", opacity: "0.12"),
          tag.path(d: line_d, fill: "none", stroke: "var(--rk-accent)", "stroke-width": 2.2, "vector-effect": "non-scaling-stroke", "stroke-linejoin": "round"),
          tag.circle(cx: last_x, cy: last_y, r: 3, fill: "var(--rk-accent)")
        ]
      )
    end
  end

  # Progress ring used for the "AI Visibility Score" hero mockup.
  def rk_donut_ring(percent, label, size: 76)
    r = 32
    circumference = 2 * Math::PI * r
    offset = (circumference * (1 - (percent / 100.0))).round(2)

    content_tag(:div, style: "position:relative;width:#{size}px;height:#{size}px") do
      safe_join([
        content_tag(:svg, width: size, height: size, viewBox: "0 0 80 80", style: "transform:rotate(-90deg)") do
          safe_join([
            tag.circle(cx: 40, cy: 40, r: r, fill: "none", stroke: "var(--rk-line-soft)", "stroke-width": 8),
            tag.circle(cx: 40, cy: 40, r: r, fill: "none", stroke: "var(--rk-accent)", "stroke-width": 8,
              "stroke-dasharray": circumference.round(2), "stroke-dashoffset": offset)
          ])
        end,
        content_tag(:div, style: "position:absolute;inset:0;display:grid;place-items:center") do
          content_tag(:span, label, style: "font-family:'Archivo',sans-serif;font-weight:800;font-size:16px;color:var(--rk-accent)")
        end
      ])
    end
  end

  # Helper for rendering navigation links.
  DEFAULT_NAV_LINKS = [
      { label: "Features", href: "#features" },
      { label: "Pricing",  href: "#pricing" },
      { label: "FAQ",      href: "#faq" }
    ].freeze

  # Helper for rendering legal links.
  DEFAULT_LEGAL_LINKS = [
    { label: "Privacy", href: "/privacy" },
    { label: "Terms",   href: "/terms" },
    { label: "Security", href: "/security" }
  ].freeze
end
