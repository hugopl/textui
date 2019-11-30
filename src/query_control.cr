class QueryControl
  def initialize(ui : TextUi::Ui)
    default_query = ""
    @query_box = TextUi::Box.new(ui, "Query", "F2")
    @editor = TextUi::TextEditor.new(@query_box, 1, 1, 0, 0)
    @editor.show_line_numbers = true
    @editor.word_wrap = true
    {% if !flag?(:release) %}
      @editor.text = "SELECT * FROM users;"
    {% end %}
    ui.focus(@editor)

    @dbs_box = TextUi::Box.new(ui, "Databases", "F3")
    @dbs_list = TextUi::List.new(@dbs_box, 1, 1)
    @dbs_list.width = 18
    # @dbs_list.on_select = ->(db : String) { ui.change_database(db) }

    ui.add_focus_shortcut(TextUi::KEY_F2, @editor)
    ui.add_focus_shortcut(TextUi::KEY_F3, @dbs_list)
  end

  def query
    @editor.text
  end

  def query=(sql)
    @editor.text = sql
  end

  def on_database_selected=(proc)
    @dbs_list.on_select = proc
  end

  def available_databases=(databases)
    @dbs_list.items = databases
  end

  def selected_database=(database)
    @dbs_list.select(database)
  end

  def handle_resize(width, height)
    @query_box.width = width - 19
    @query_box.height = height//2
    @editor.width = @query_box.width - 2
    @editor.height = @query_box.height - 2

    @dbs_box.width = 20
    @dbs_box.height = height//2
    @dbs_box.right_of(@query_box)
    @dbs_list.height = @dbs_box.height - 2
  end
end
