# this is somewhat duplicative of the table_print gem, but tbh I like that we
# don't have many dependencies yet, so I'd rather keep it this way.
class Bundler::Stats::Printer
  attr_accessor :headers, :data, :borders

  MIN_COL_SIZE = 10

  BORDERS = {
    on: { corner: "+", horizontal: "-", vertical: "|" },
    off: { corner: " ", horizontal: " ", vertical: " " },
  }

  def initialize(headers: nil, data: [], borders: true)
    @headers  = headers
    @data     = data
    @borders  = borders ? BORDERS[:on] : BORDERS[:off]
  end

  def to_s
    table_data = ([headers] + data).compact
    col_widths = column_widths(table_data)

    lines = []
    lines << separator_row(col_widths)

    if headers
      lines << aligned_row(headers, col_widths)
      lines << separator_row(col_widths)
    end

    data.each do |row|
      lines += split_rows(row, col_widths)
    end
    lines << separator_row(col_widths)

    lines.join("\n")
  end

  def terminal_width
    Integer(Kernel.send(:"`", "tput cols"))
  rescue StandardError
    80
  end

  def column_widths(table_data)
    num_cols  = table_data.first.length
    chrome    = 2 + 2 + (num_cols - 1) * 3

    # doesn't fit at all
    if chrome + (num_cols * MIN_COL_SIZE) > terminal_width
      raise ArgumentError, "Table smooshed. Refusing to print table."
    end

    data_widths = 0.upto(num_cols - 1).map do |idx|
      max_width(table_data.map { |row| row[idx] })
    end

    # fits comfortably
    if data_widths.inject(&:+) + chrome < terminal_width
      return data_widths
    end

    free_space = terminal_width
    free_space -= chrome
    free_space -= MIN_COL_SIZE * num_cols

    # fit uncomfortably
    widths = [MIN_COL_SIZE] * num_cols
    data_widths.each_with_index do |width, idx|
      next unless width > widths[idx]

      allocated = [width, free_space].min

      if allocated > 0
        widths[idx] += allocated
        free_space  -= allocated
      end
    end

    widths
  end

  private

  def max_width(data)
    data.map do |value|
      Array(value).join(", ").length
    end.max
  end

  def separator_row(col_widths)
    sep = "#{borders[:horizontal]}#{borders[:vertical]}#{borders[:horizontal]}"

    "#{borders[:corner]}#{borders[:horizontal]}" +
      col_widths.map { |width| borders[:horizontal] * width }.join(sep) +
      "#{borders[:horizontal]}#{borders[:corner]}"
  end

  def split_rows(row, col_widths)
    return [] unless row.find { |v| v && v.length > 0 }

    rows_with_splits = [row]
    next_row = []

    joined_data = row.each_with_index.map do |val, idx|
      words         = Array(val).map(&:to_s)
      target_width  = col_widths[idx]

      (cell, remainder) = row_and_remainder(words, target_width)

      next_row[idx] = remainder
      cell
    end

    ([aligned_row(joined_data, col_widths)] +
      split_rows(next_row, col_widths)).compact
  end

  def row_and_remainder(words, target_width)
    if(words.join(", ").length < target_width)
      return [words.join(", "), nil]
    end

    this_row = []
    while words.length > 0 && (this_row.join(", ").length + words[0].length) <= target_width
      this_row << words.shift
    end

    [this_row.join(", "), words]
  end

  def aligned_row(row, col_widths)
    aligned_values = row.each_with_index.map do |data, idx|
      if idx == 0
        data.rjust(col_widths[idx])
      else
        data.ljust(col_widths[idx])
      end
    end

    "#{borders[:vertical]} " + aligned_values.join(" #{borders[:vertical]} ") + " #{borders[:vertical]}"
  end
end
