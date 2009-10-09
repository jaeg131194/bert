require 'test_helper'

class EncoderTest < Test::Unit::TestCase
  context "BERT Encoder complex type converter" do
    should "convert nil" do
      assert_equal [:nil, :nil], BERT::Encoder.convert(nil)
    end

    should "convert nested nil" do
      before = [nil, [nil]]
      after = [[:nil, :nil], [[:nil, :nil]]]
      assert_equal after, BERT::Encoder.convert(before)
    end

    should "convert hashes" do
      before = {:foo => 'bar'}
      after = [:dict, [[:foo, 'bar']]]
      assert_equal after, BERT::Encoder.convert(before)
    end

    should "convert nested hashes" do
      before = {:foo => {:baz => 'bar'}}
      after = [:dict, [[:foo, [:dict, [[:baz, "bar"]]]]]]
      assert_equal after, BERT::Encoder.convert(before)
    end

    should "convert hash to tuple with array of tuples" do
      arr = BERT::Encoder.convert({:foo => 'bar'})
      assert arr.is_a?(Array)
      assert arr[1].is_a?(Erl::List)
      assert arr[1][0].is_a?(Array)
    end

    should "convert tuple to array" do
      arr = BERT::Encoder.convert(t[:foo, 2])
      assert arr.is_a?(Array)
    end

    should "convert array to erl list" do
      list = BERT::Encoder.convert([1, 2])
      assert list.is_a?(Erl::List)
    end

    should "convert an array in a tuple" do
      arrtup = BERT::Encoder.convert(t[:foo, [1, 2]])
      assert arrtup.is_a?(Array)
      assert arrtup[1].is_a?(Erl::List)
    end

    should "convert true" do
      before = true
      after = [:bool, :true]
      assert_equal after, BERT::Encoder.convert(before)
    end

    should "convert false" do
      before = false
      after = [:bool, :false]
      assert_equal after, BERT::Encoder.convert(before)
    end

    should "convert times" do
      before = Time.at(1254976067)
      after = [:time, 1254976067, 0]
      assert_equal after, BERT::Encoder.convert(before)
    end

    should "convert regexen" do
      before = /^c(a)t$/ix
      after = [:regex, '^c(a)t$', 'ix']
      assert_equal after, BERT::Encoder.convert(before)
    end

    should "properly convert types" do
      ruby = t[:user, {:name => 'TPW'}, [/cat/i, 9.9], nil, true, false, :true, :false]
      cruby = BERT::Encoder.convert(ruby)
      assert cruby.instance_of?(Array)
      assert cruby[0].instance_of?(Symbol)
      assert cruby[1].instance_of?(Array)
    end

    should "leave other stuff alone" do
      before = [1, 2.0, [:foo, 'bar']]
      assert_equal before, BERT::Encoder.convert(before)
    end
  end
end