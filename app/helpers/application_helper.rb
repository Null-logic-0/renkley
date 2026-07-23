module ApplicationHelper
  def initials(full_name)
    full_name.split(" ").map(&:chr).join
  end
end
