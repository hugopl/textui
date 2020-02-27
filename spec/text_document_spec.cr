require "./spec_helper"

describe TextUi::TextDocument do
  it "stores previous block" do
    doc = TextUi::TextDocument.new
    doc.contents = "line0"
    doc.insert_line(1, "line1")
    doc.insert_line(2, "line3")
    doc.insert_line(2, "line2")

    doc.blocks[3].text.should eq("line3")
    doc.blocks[3].previous_block.text.should eq("line2")
    doc.blocks[3].next_block?.should eq(nil)
    doc.blocks[2].text.should eq("line2")
    doc.blocks[2].previous_block.text.should eq("line1")
    doc.blocks[2].next_block.text.should eq("line3")
    doc.blocks[1].text.should eq("line1")
    doc.blocks[1].previous_block.text.should eq("line0")
    doc.blocks[1].next_block.text.should eq("line2")
    doc.blocks[0].text.should eq("line0")
    doc.blocks[0].previous_block?.should eq(nil)
    doc.blocks[0].next_block.text.should eq("line1")

    # line 0
    # line 1
    # line 2 <- remove this
    # line 3
    doc.remove_line(2)
    doc.blocks.size.should eq(3)
    doc.blocks[2].text.should eq("line3")
    doc.blocks[2].previous_block.text.should eq("line1")
    doc.blocks[2].next_block?.should eq(nil)
    doc.blocks[1].text.should eq("line1")
    doc.blocks[1].previous_block.text.should eq("line0")
    doc.blocks[1].next_block.text.should eq("line3")
    doc.blocks[0].text.should eq("line0")
    doc.blocks[0].previous_block?.should eq(nil)
    doc.blocks[0].next_block.text.should eq("line1")

    # line 0
    # line 1
    # line 3 <- remove this
    doc.remove_line(2)
    doc.blocks[1].text.should eq("line1")
    doc.blocks[1].previous_block.text.should eq("line0")
    doc.blocks[1].next_block?.should eq(nil)
    doc.blocks[0].text.should eq("line0")
    doc.blocks[0].previous_block?.should eq(nil)
    doc.blocks[0].next_block.text.should eq("line1")

    # line 0 <- remove this
    # line 1
    doc.remove_line(0)
    doc.blocks[0].text.should eq("line1")
    doc.blocks[0].previous_block?.should eq(nil)
    doc.blocks[0].next_block?.should eq(nil)
  end

  it "stores previous block when loading all lines" do
    doc = TextUi::TextDocument.new
    doc.contents = "line0\nline1\nline2\nline3"

    doc.blocks[3].text.should eq("line3")
    doc.blocks[3].previous_block.text.should eq("line2")
    doc.blocks[3].next_block?.should eq(nil)
    doc.blocks[2].text.should eq("line2")
    doc.blocks[2].previous_block.text.should eq("line1")
    doc.blocks[2].next_block.text.should eq("line3")
    doc.blocks[1].text.should eq("line1")
    doc.blocks[1].previous_block.text.should eq("line0")
    doc.blocks[1].next_block.text.should eq("line2")
    doc.blocks[0].text.should eq("line0")
    doc.blocks[0].previous_block?.should eq(nil)
    doc.blocks[0].next_block.text.should eq("line1")
  end

  it "do not send clean state changed if it didn't change" do
    doc = TextUi::TextDocument.new
    call_counter = 0
    doc.clean_state_changed.on do
      call_counter += 1
    end
    doc.contents = "line0\nline1\nline2\nline3"
    call_counter.should eq(0)

    buffer = IO::Memory.new(64)
    doc.save(buffer)
    call_counter.should eq(0)
    doc.save(buffer)
    call_counter.should eq(0)
  end
end
