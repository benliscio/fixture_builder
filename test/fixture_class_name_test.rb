require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

module Books
  class << self
    def table_name_prefix
      "books_"
    end
  end
end

class Books::Novel < ActiveRecord::Base
end
class FixtureClassNameTest < Test::Unit::TestCase
  def setup
    create_and_blow_away_old_db
    force_fixture_generation

    ActiveRecord::Base.connection.create_table(:books_novels, :force => true) do |t|
      t.column :name, :string
    end

    ActiveRecord::Base.connection.create_table(:books_non_fictions, :force => true) do |t|
      t.column :name, :string
    end

    @@table_name_to_class_map = { books_novels: Books::Novel }

    FixtureBuilder.configure do |fbuilder|
      fbuilder.legacy_fixtures = Dir[test_path("legacy_fixtures/*.yml"), test_path("other_legacy_fixture_set/*.yml")]
      fbuilder.table_name_to_class_map = @@table_name_to_class_map

      fbuilder.factory do
        MagicalCreature.create(:name => "frank", :species => "unicorn")
        Books::Novel.create(:name => "The Loch Ness monster")
      end
    end

    @@magical_creatures  = YAML.load(File.open(test_path("fixtures/magical_creatures.yml")))
    @@books_novels       = YAML.load(File.open(test_path("fixtures/books_novels.yml")))
    @@books_non_fictions = YAML.load(File.open(test_path("fixtures/books_non_fictions.yml")))
  end

  def teardown
    FixtureBuilder.send(:remove_instance_variable, :@configuration)
  end

  def test_model_name_automatically_inferred
    assert_equal "MagicalCreature", @@magical_creatures["_fixture"]["model_class"]
  end

  def test_model_name_set_when_map_present
    assert_equal "Books::Novel", @@books_novels["_fixture"]["model_class"]
  end

  def test_model_name_when_class_and_table_name_class_map_missing
    assert_equal nil, @@books_non_fictions["_fixture"]
  end
end
