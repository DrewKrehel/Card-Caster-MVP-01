module ApplicationHelper
  def render_breadcrumbs
    return unless @breadcrumbs.present?

    content_tag :nav, aria: { label: "Breadcrumb" }, class: "container mt-3" do
      content_tag :ol, class: "breadcrumb" do
        @breadcrumbs.map do |crumb|
          if crumb[:url]
            content_tag :li, class: "breadcrumb-item" do
              link_to crumb[:name], crumb[:url]
            end
          else
            content_tag :li, crumb[:name], class: "breadcrumb-item active", aria: { current: "page" }
          end
        end.join.html_safe
      end
    end
  end
end
