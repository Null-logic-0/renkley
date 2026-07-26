module ChartHelper
  def chart_score_ring(value, grade:, size: 94, stroke: 9)
    radius = (size / 2.0) - (stroke / 2.0) - 1
    circumference = 2 * Math::PI * radius
    offset = circumference * (1 - value.to_f / 100)
    center = size / 2.0

    content_tag :div, class: "rk-chart-ring", style: "width:#{size}px;height:#{size}px" do
      safe_join([
        content_tag(:svg, width: size, height: size, viewBox: "0 0 #{size} #{size}",
                    style: "transform:rotate(-90deg)", "aria-hidden": true) do
          safe_join([
            tag.circle(cx: center, cy: center, r: radius, fill: "none", stroke: "var(--rk-line-soft)", "stroke-width": stroke),
            tag.circle(cx: center, cy: center, r: radius, fill: "none", stroke: "var(--rk-accent)", "stroke-width": stroke,
                       "stroke-dasharray": circumference, "stroke-dashoffset": offset, "stroke-linecap": "butt")
          ])
        end,
        content_tag(:div, class: "rk-chart-ring-label") do
          safe_join([ content_tag(:span, grade, class: "rk-chart-ring-grade"), content_tag(:span, "GRADE", class: "rk-chart-ring-caption") ])
        end
      ])
    end
  end

  def chart_sparkline(values, color:, width: 100, height: 32)
    return content_tag(:span, "", class: "rk-chart-empty") if values.blank? || values.size < 2

    points = spark_points(values, width, height)
    line = svg_path(points)
    area = "#{line} L #{width} #{height} L 0 #{height} Z"
    last = points.last

    content_tag(:svg, width: "100%", height: height, viewBox: "0 0 #{width} #{height}", preserveAspectRatio: "none",
                style: "display:block", "aria-hidden": true) do
      safe_join([
        tag.path(d: area, fill: color, opacity: 0.12),
        tag.path(d: line, fill: "none", stroke: color, "stroke-width": 1.8, "stroke-linecap": "round", "stroke-linejoin": "round"),
        tag.circle(cx: last[0].round(1), cy: last[1].round(1), r: 2.4, fill: color)
      ])
    end
  end

  def chart_area_line(values, labels:, color:, width: 680, height: 250, max: nil)
    return content_tag(:p, "Not enough scan history yet.", class: "rk-chart-empty") if values.blank? || values.size < 2

    max_v = max || [ values.max, 1 ].max
    pad_b = 24
    inner_h = height - pad_b
    points = values.each_with_index.map { |v, i| [ x_for(i, values.size, width), inner_h - (v.to_f / max_v * inner_h) ] }
    line = svg_path(points)
    area = "#{line} L #{width} #{inner_h} L 0 #{inner_h} Z"

    content_tag(:div, class: "rk-chart-area", style: "position:relative;width:100%;height:#{height}px") do
      safe_join([
        content_tag(:svg, width: "100%", height: height, viewBox: "0 0 #{width} #{height}", preserveAspectRatio: "none",
                    style: "display:block", "aria-hidden": true) do
          safe_join([
            tag.path(d: area, fill: color, opacity: 0.12),
            tag.path(d: line, fill: "none", stroke: color, "stroke-width": 2.4, "stroke-linejoin": "round")
          ])
        end,
        chart_x_labels(labels, width, pad_b)
      ])
    end
  end

  def chart_dual_area_line(labels:, series_a:, series_a_color:, series_b:, series_b_color:, width: 680, height: 250)
    return content_tag(:p, "Not enough scan history yet.", class: "rk-chart-empty") if series_a.blank? || series_a.size < 2

    max_v = [ series_a.max, series_b.max, 1 ].max
    pad_b = 24
    inner_h = height - pad_b
    n = series_a.size
    points_for = ->(vals) { vals.each_with_index.map { |v, i| [ x_for(i, n, width), inner_h - (v.to_f / max_v * inner_h) ] } }
    a_points = points_for.call(series_a)
    b_points = points_for.call(series_b)
    a_line = svg_path(a_points)
    b_line = svg_path(b_points)
    a_area = "#{a_line} L #{width} #{inner_h} L 0 #{inner_h} Z"

    content_tag(:div, class: "rk-chart-area", style: "position:relative;width:100%;height:#{height}px") do
      safe_join([
        content_tag(:svg, width: "100%", height: height, viewBox: "0 0 #{width} #{height}", preserveAspectRatio: "none",
                    style: "display:block", "aria-hidden": true) do
          safe_join([
            tag.path(d: a_area, fill: series_a_color, opacity: 0.10),
            tag.path(d: a_line, fill: "none", stroke: series_a_color, "stroke-width": 2),
            tag.path(d: b_line, fill: "none", stroke: series_b_color, "stroke-width": 2, "stroke-dasharray": "4 4")
          ])
        end,
        chart_x_labels(labels, width, pad_b)
      ])
    end
  end

  def chart_donut(segments, center_label:, center_value:, size: 140, stroke: 22)
    radius = (size / 2.0) - (stroke / 2.0) - 1
    circumference = 2 * Math::PI * radius
    center = size / 2.0
    acc = 0.0

    circles = segments.map do |seg|
      length = seg[:pct].to_f / 100 * circumference
      offset = -acc
      acc += length
      tag.circle(cx: center, cy: center, r: radius, fill: "none", stroke: seg[:color], "stroke-width": stroke,
                 "stroke-dasharray": "#{length} #{circumference - length}", "stroke-dashoffset": offset)
    end

    content_tag(:div, class: "rk-chart-donut", style: "width:#{size}px;height:#{size}px") do
      safe_join([
        content_tag(:svg, width: size, height: size, viewBox: "0 0 #{size} #{size}",
                    style: "transform:rotate(-90deg)", "aria-hidden": true) { safe_join(circles) },
        content_tag(:div, class: "rk-chart-donut-label") do
          safe_join([ content_tag(:span, center_value, class: "rk-chart-donut-value"), content_tag(:span, center_label, class: "rk-chart-donut-caption") ])
        end
      ])
    end
  end

  private

  def x_for(index, count, width) = count <= 1 ? 0.0 : (index.to_f / (count - 1)) * width

  def spark_points(values, width, height)
    min = values.min
    max = values.max
    span = (max - min).nonzero? || 1
    values.each_with_index.map { |v, i| [ x_for(i, values.size, width), height - 3 - ((v - min).to_f / span * (height - 6)) ] }
  end

  def svg_path(points)
    points.each_with_index.map { |(x, y), i| "#{i.zero? ? "M" : "L"} #{x.round(1)} #{y.round(1)}" }.join(" ")
  end

  def chart_x_labels(labels, width, pad_b)
    content_tag(:div, style: "position:absolute;left:0;right:0;bottom:0;height:#{pad_b}px") do
      safe_join(labels.each_with_index.map { |l, i|
        left_pct = labels.size <= 1 ? 0 : (i.to_f / (labels.size - 1) * 100)
        content_tag(:span, l, style: "position:absolute;left:#{left_pct}%;top:6px;transform:translateX(-50%);font-size:10.5px;color:var(--rk-faint);white-space:nowrap")
      })
    end
  end
end
