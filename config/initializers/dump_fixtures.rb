# frozen_string_literal: true

module ActiveRecord
  class Base
    def dump_fixture
      fixture_file = "#{Rails.root}/test/fixtures/#{self.class.table_name}.yml"
      File.open(fixture_file, "a+") do |f|
        f.puts(
          {"#{self.class.table_name.singularize}_#{id}" => attributes.except("created_at", "updated_at")}
            .to_yaml
            .sub!(/---\s?/, "\n")
        )
      end
    end
  end
end
