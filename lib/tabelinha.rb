module Tabelinha
  module_function

  # Generates a formatted table with customizable options.
  #
  # @param rows [Array<Array<String>>] An array of rows, where each row is an array of cells to be displayed in the table.
  # @param options [Hash] An optional hash of configuration options to customize the appearance of the table.
  # @option options [Boolean] :space_linebroken (true) If true, adds extra space between rows with line breaks.
  # @option options [Integer] :padding (1) The number of spaces padding each cell.
  # @option options [Float] :max_width (Float::INFINITY) The maximum width of the table.
  # @option options [Hash] :corners Hash containing characters for table corners.
  #   @option options [String] :top_right ('┌') Character for the top-right corner.
  #   @option options [String] :top_left ('┐') Character for the top-left corner.
  #   @option options [String] :bottom_right ('└') Character for the bottom-right corner.
  #   @option options [String] :bottom_left ('┘') Character for the bottom-left corner.
  # @option options [Hash] :straight Hash containing characters for straight lines.
  #   @option options [String] :vertical ('│') Character for vertical lines.
  #   @option options [String] :horizontal ('─') Character for horizontal lines.
  # @option options [Hash] :junctions Hash containing characters for junctions.
  #   @option options [String] :top ('┬') Character for the top junction.
  #   @option options [String] :middle ('┼') Character for the middle junction.
  #   @option options [String] :bottom ('┴') Character for the bottom junction.
  #
  # @example
  #   rows = [
  #     ['Header 1', 'Header 2', 'Header 3'],
  #     ['Value 1', 'Value 2', 'Value 3'],
  #     ['Another Value 1', 'Another Value 2', 'Another Value 3']
  #   ]
  #
  #   options = {
  #     space_linebroken: true,
  #     padding: 1,
  #     max_width: 80,
  #     corners: { top_right: '┌', top_left: '┐', bottom_right: '└', bottom_left: '┘' },
  #     straight: { vertical: '│', horizontal: '─' },
  #     junctions: { top: '┬', middle: '┼', bottom: '┴' }
  #   }
  #
  #   table(rows, options)
  #
  # This method generates a formatted table with the specified rows and options. It supports various formatting elements
  # to provide flexibility in table appearance.

  def table(rows, options = {})
    # sets options

    options = {
      space_linebroken: true,
      padding: 1,
      max_width: Float::INFINITY,
      corners: {
        top_right: '┌',
        top_left: '┐',
        bottom_right: '└',
        bottom_left: '┘'
      },
      straight: {
        vertical: '│',
        horizontal: '─'
      },
      junctions: {
        top: '┬',
        middle: '┼',
        bottom: '┴'
      }
    }.merge(options)

    padding_amount = options[:padding]
    padding = ' ' * padding_amount

    # split \n and normalize rows

    newline_treated_rows = []

    rows.each do |row|
      max_size = 0
      split_row = row.map do |cell|
        split_cells = cell.split("\n")
        max_size = split_cells.length if split_cells.length > max_size
        split_cells
      end.map do |split_cells|
        split_cells += Array.new(max_size - split_cells.length, '')
      end.transpose

      newline_treated_rows += split_row
      if options[:space_linebroken] && split_row.length > 1
        newline_treated_rows << Array.new(split_row.first.length,
                                          ' ')
      end
    end

    rows = newline_treated_rows

    # set widths for each column to be printed, fitting terminal size

    columns = rows.transpose

    total_column_width = options[:max_width] - columns.length - 1
    current_column_widths = columns.map { |column| column.map { |cell| cell.gsub(/\e\[([;\d]+)?m/, '').length }.max }

    actual_column_widths = current_column_widths
    if current_column_widths.sum > total_column_width
      even_width_per_column = total_column_width / columns.length
      even_width_per_column = 1 if even_width_per_column.zero?

      width_for_linebroken = total_column_width - actual_column_widths.select { |n| n < even_width_per_column }.sum

      actual_column_widths = current_column_widths.map do |width|
        width > even_width_per_column ? even_width_per_column : width
      end
    end

    # write the top of the table

    table = ''
    table << options.dig(:corners, :top_right)
    table << actual_column_widths.map do |width|
      str = ''
      str << options.dig(:straight, :horizontal) * width
      str << options.dig(:straight, :horizontal) * padding_amount * 2
    end.join(options.dig(:junctions, :top))

    table << options.dig(:corners, :top_left)
    table << "\n"

    # write the contents of the table(breaks lines if needed)

    rows.each do |row|
      stripped_columns = row.map.with_index do |cell, column_i|
        width = actual_column_widths[column_i]
        cell.chars.each { |a| }
        no_ansi = cell.gsub(/\e\[([;\d]+)?m/, '')

        divide_cell(cell, width)
      end

      height = stripped_columns.map(&:length).max
      height += 1 if height > 1 && options[:space_linebroken]
      new_columns = stripped_columns.map.with_index do |column, column_i|
        width = actual_column_widths[column_i]
        column.fill(' ' * width, column.length..(height - 1))
        column
      end

      table << new_columns.transpose.map do |row|
        str = ''
        str << options.dig(:straight, :vertical) + padding
        str << row.join(padding + options.dig(:straight, :vertical) + padding)
        str << padding + options.dig(:straight, :vertical)
      end.join("\n")
      table << "\n"
    end

    # writes the bottom of the table

    table << options.dig(:corners, :bottom_right)
    table << actual_column_widths.map do |width|
      str = ''
      str << options.dig(:straight, :horizontal) * width
      str << options.dig(:straight, :horizontal) * padding_amount * 2
    end.join(options.dig(:junctions, :bottom))
    table << options.dig(:corners, :bottom_left)
    table << "\n"
  end

  private_class_method def divide_cell(cell, width)
    buckets = []
    current_bucket = { content: '', ansi_codes: [] }
    current_ansi = { content: '', start_index: 0, end_index: -1 }
    inside_ansi = false

    cell.chars.each do |char|
      if (char == "\e") || inside_ansi
        current_ansi[:start_index] = current_bucket[:content].length
        current_ansi[:content] << char
        inside_ansi = char != 'm'

        if !inside_ansi
          current_bucket[:ansi_codes] << current_ansi
          current_ansi = { content: '', start_index: 0, end_index: -1 }
        end

        next
      end

      current_bucket[:content] << char
      next if current_bucket[:content].length < width

      buckets << current_bucket
      current_bucket = { content: '', ansi_codes: [] }
      current_bucket[:ansi_codes] = buckets.last[:ansi_codes].select { |ac| ac[:end_index] == -1 }.map do |ac|
        { content: ac[:content], start_index: 0, end_index: -1 }
      end
    end

    if !current_bucket[:content].empty?
      current_bucket[:content] = current_bucket[:content].ljust(width)
      buckets << current_bucket
    end

    ansi_code_end = "\e[m"
    buckets.map do |bucket|
      content_result = bucket[:content]

      bucket[:ansi_codes].sort_by { |ac| ac[:end_index] == -1 ? Float::INFINITY : ac[:end_index] }.reverse.each do |ac|
        content_result.insert(ac[:end_index], ansi_code_end)
      end

      bucket[:ansi_codes].sort_by { |ac| ac[:start_index] }.reverse.each do |ac|
        content_result.insert(ac[:start_index], ac[:content])
      end

      content_result
    end
  end
end
