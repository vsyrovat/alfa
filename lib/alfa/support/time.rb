class Time
  def ago
    (::Time.now - self).to_i
  end
end