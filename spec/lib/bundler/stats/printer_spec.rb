require 'bundler'
require 'bundler/stats'

describe Bundler::Stats::Printer do
  subject { described_class }

  def set_term_width(width)
    allow(Kernel).to receive(:"`").and_return(width)
  end

  describe "#terminal_width" do
    context "*nix systems" do
      it "return the kernel width" do
        set_term_width(180)

        printer   = subject.new
        response  = printer.terminal_width

        expect(response).to eq(180)
      end
    end

    context "non-*nix systems" do
      it "always returns a small number" do
        set_term_width(nil)

        printer   = subject.new
        response  = printer.terminal_width

        expect(response).to eq(80)
      end
    end
  end

  describe "#column_widths" do
    it "comfortably prints tables of comfortable data" do
        set_term_width(80)
        printer     = subject.new
        table_data  = [
          [ "name", "data" ],
          [ "*" * 10, "*" * 20 ],
        ]

        widths = printer.column_widths(table_data)

        expect(widths).to eq([10, 20])
    end

    it "smooshes uncomfortably long data" do
        set_term_width(60)
        printer     = subject.new
        table_data  = [
          [ "name", "data" ],
          [ "*" * 10, "*" * 60 ],
        ]

        widths = printer.column_widths(table_data)

        target_widths = [10, 43] # 7 for gutters
        expect(widths).to eq(target_widths)
    end

    it "always allows some amount of space for data" do
        set_term_width(60)
        printer     = subject.new
        table_data  = [
          [ "name", "data1", "data2", "data3" ],
          [ "*" * 10, "*" * 60, "*" * 60, "*" * 60 ],
        ]

        widths = printer.column_widths(table_data)

        target_widths = [10, 17, 10, 10] # 13 for gutters
        expect(widths).to eq(target_widths)
    end

    it "bails if it can't handle that data" do
        set_term_width(10)
        printer     = subject.new
        table_data  = [
          [ "name", "data" ],
          [ "*" * 10, "*" * 20 ],
        ]

        expect {
          printer.column_widths(table_data)
        }.to raise_error(ArgumentError)
    end
  end

  describe "#to_s" do
    it "prints a pretty table" do
      set_term_width(80)
      printer = subject.new(headers: ["stars", "stripes"],
                            data: [["*****", "*****"]]
                           )

      output  = printer.to_s
      table   = <<-TABLE
+-------|---------+
| stars | stripes |
+-------|---------+
| ***** | *****   |
+-------|---------+
      TABLE

      expect(output).to eq(table.chomp)
    end

    it "deals with data alignment" do
      set_term_width(80)
      printer = subject.new(headers: ["name", "value"],
                            data: [
                              ["one", "*****"],
                              ["seventeen", "///////////////"]
                            ])

      output  = printer.to_s
      table   = <<-TABLE
+-----------|-----------------+
|      name | value           |
+-----------|-----------------+
|       one | *****           |
| seventeen | /////////////// |
+-----------|-----------------+
      TABLE

      expect(output).to eq(table.chomp)
    end

    it "wraps data as necessary" do
      set_term_width(35)
      printer = subject.new(headers: ["name", "value"],
                            data: [
                              ["words", ["one", "two", "three", "four", "five"]],
                            ])

      output  = printer.to_s
      table   = <<-TABLE
+------------|--------------------+
|       name | value              |
+------------|--------------------+
|      words | one, two, three    |
|            | four, five         |
+------------|--------------------+
      TABLE

      expect(output).to eq(table.chomp)
    end

    it "can wrap multiple columns" do
      set_term_width(45)
      printer = subject.new(headers: ["name", "value", "other value"],
                            data: [
                              [ "words",
                               ["one", "two", "three", "four", "five"],
                               ["six", "seven", "eight", "nine", "ten"],
                              ]
                            ])

      output  = printer.to_s
      table   = <<-TABLE
+------------|-----------------|------------+
|       name | value           | other value |
+------------|-----------------|------------+
|      words | one, two, three | six, seven |
|            | four, five      | eight, nine |
|            |                 | ten        |
+------------|-----------------|------------+
      TABLE

      expect(output).to eq(table.chomp)
    end

    it "can print without a header" do
      set_term_width(80)
      printer = subject.new(headers: nil,
                            data: [
                              ["*****", "********"],
                              ["++++++++", "+++++"],
                            ])

      output  = printer.to_s
      table   = <<-TABLE
+----------|----------+
|    ***** | ******** |
| ++++++++ | +++++    |
+----------|----------+
      TABLE

      expect(output).to eq(table.chomp)
    end

    it "can print without separators at all!" do
      set_term_width(80)
      printer = subject.new(headers: nil,
                            borders: false,
                            data: [
                              ["*****", "********"],
                              ["++++++++", "+++++"],
                            ])

      output  = printer.to_s
      table   = <<-TABLE
                       
     *****   ********  
  ++++++++   +++++     
                       
      TABLE

      expect(output).to eq(table.chomp)
    end
  end
end
