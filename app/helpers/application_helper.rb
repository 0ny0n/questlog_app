module ApplicationHelper
  def render_mentions(rich_text)
    html = rich_text.to_s
    html.gsub(/<a[^>]*(?:data-trix-mention="(\d+)"|href="\/users\/(\d+)")[^>]*>.*?<\/a>/m) do
      user_id = ($1 || $2).to_i
      user = User.find_by(id: user_id)

      if user
        link_to "@#{user.username}", user_path(user), class: "mention-chip"
      else
        "<span class='mention-deleted'>@deleted-user</span>"
      end
    end.html_safe
  end
end
