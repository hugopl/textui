require "./spec_helper"

describe TextUi::Table do
  it "moves view port to right when needed" do
    ui = init_ui(12, 2)
    table = TextUi::Table.new(ui)
    table.resize(12, 2)
    ui.focus(table)

    table.set_data([%w(ABCD EFGH IJKL MNOP QRST),
                    %w(abcd efgh ijkl mnop qrst)])
    ui.render
    table.cursor_x.should eq(0)
    Terminal.to_s.should eq("ABCD EFGH I…\n" \
                            "abcd efgh i…\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_RIGHT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(1)
    Terminal.to_s.should eq("ABCD EFGH I…\n" \
                            "abcd efgh i…\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_RIGHT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(2)
    Terminal.to_s.should eq("…D EFGH IJKL\n" \
                            "…d efgh ijkl\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_RIGHT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(3)
    Terminal.to_s.should eq("…H IJKL MNOP\n" \
                            "…h ijkl mnop\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(2)
    Terminal.to_s.should eq("…H IJKL MNOP\n" \
                            "…h ijkl mnop\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(1)
    Terminal.to_s.should eq("EFGH IJKL M…\n" \
                            "efgh ijkl m…\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(0)
    Terminal.to_s.should eq("ABCD EFGH I…\n" \
                            "abcd efgh i…\n")
  end

  it "clean screen garbage when rendering" do
    ui = init_ui(10, 4)
    table = TextUi::Table.new(ui)
    table.resize(10, 4)
    table.set_data([%w(Col0 Col1 Col4),
                    %w(row1 row1 row1),
                    %w(row2 row2 row2),
                    %w(row3 row3 row3)])
    ui.render
    Terminal.to_s.should eq("Col0 Col1 \n" \
                            "row1 row1 \n" \
                            "row2 row2 \n" \
                            "row3 row3 \n")
    table.set_data([%w(A), %w(a)])
    ui.render
    Terminal.to_s.should eq("A         \n" \
                            "a         \n" \
                            "          \n" \
                            "          \n")
  end
end
