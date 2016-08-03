class Fixnum
  # Ordinal returns the suffix used to denote the position
  # in an ordered sequence such as 1st, 2nd, 3rd, 4th.
  #
  #  1.ordinal     # => "st"
  #  2.ordinal     # => "nd"
  #  1002.ordinal  # => "nd"
  #  1003.ordinal  # => "rd"
  #  -11.ordinal   # => "th"
  #  -1001.ordinal # => "st"
  def ordinal
    abs_number = self.to_i.abs

      if (11..13).include?(abs_number % 100)
        "th"
      else
        case abs_number % 10
          when 1; "st"
          when 2; "nd"
          when 3; "rd"
          else    "th"
        end
      end
  end
end