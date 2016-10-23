module SinsHelper
  def as_currency(cents)
    dollars = '%.2f' % (cents.to_f/100)
    return "$#{dollars}"
  end
end
