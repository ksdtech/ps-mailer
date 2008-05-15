module FamiliesHelper
  def alpha_links(fams)
    # fams ignored for now
    links = %w( A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ).inject([]) do |a, ltr|
      a.push("<a href=\"/families/?alpha=#{ltr}\">#{ltr}</a>")
      a
    end
    links.push("<a href=\"/families\">All</a>")
    "<div class=\"alpha\">#{links.join(' ')}</div>"
  end
end
