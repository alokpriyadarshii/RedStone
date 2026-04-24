# frozen_string_literal: true

require_relative 'test_helper'

class ChronicleStoreTest < Minitest::Test
  def with_tmp_store
    Dir.mktmpdir do |dir|
      store = Chronicle::Store.new(dir: dir)
      store.init!
      yield store
    end
  end

  def test_add_and_list
    with_tmp_store do |store|
      e1 = Chronicle::Entry.build(message: 'hello', kind: 'note', tags: %w[a b], meta: { 'x' => '1' })
      store.add!(e1)

      list = store.list(limit: 10)

      assert_equal 1, list.size
      assert_equal 'hello', list.first.message
      assert_includes list.first.tags, 'a'
    end
  end

  def test_search
    with_tmp_store do |store|
      store.add!(Chronicle::Entry.build(message: 'Ship it', tags: ['release']))
      store.add!(Chronicle::Entry.build(message: 'Refactor', tags: ['dev']))

      hits = store.search('ship', limit: 10)

      assert_equal 1, hits.size
      assert_equal 'Ship it', hits.first.message
    end
  end

  def test_search_rejects_blank_query
    with_tmp_store do |store|
      store.add!(Chronicle::Entry.build(message: 'Ship it', tags: ['release']))
      assert_raises(Chronicle::UserError) { store.search('   ', limit: 10) }
    end
  end

  def test_export_jsonl
    with_tmp_store do |store|
      store.add!(Chronicle::Entry.build(message: 'one'))
      store.add!(Chronicle::Entry.build(message: 'two'))
      out = store.export(format: :jsonl)

      assert_includes out, '"message":"one"'
      assert_includes out, '"message":"two"'
      assert_operator out.lines.count, :>=, 2
    end
  end

  def test_export_accepts_case_insensitive_format
    with_tmp_store do |store|
      store.add!(Chronicle::Entry.build(message: 'one'))
      out = store.export(format: 'JSONL')

      assert_includes out, '"message":"one"'
    end
  end

  def test_filters
    with_tmp_store do |store|
      store.add!(Chronicle::Entry.build(message: 'a', kind: 'note', tags: ['x']))
      store.add!(Chronicle::Entry.build(message: 'b', kind: 'task', tags: ['y']))

      assert_equal 1, store.list(limit: 10, kind: 'task').size
      assert_equal 1, store.list(limit: 10, tag: 'x').size
    end
  end
end
