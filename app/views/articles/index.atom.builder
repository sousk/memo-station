atom_feed do |feed|
  feed.title(APPLICATION_TITLE)
  feed.updated(@articles.first.created_at)

  for post in @articles
    feed.entry(post) do |entry|
      entry.title(post.subject)
      entry.content(post.body, :type => 'html')
      entry.author(post.user ? post.user.login : 'anonymous')
    end
  end
end
