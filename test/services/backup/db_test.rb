require "test_helper"
require "minitest/mock"

class BackupDbTest < ActiveSupport::TestCase
  test "calls dump and upload" do
    backup = Backup::Db.new
    dump_called = false
    upload_called = false

    backup.stub(:dump, -> {
      dump_called = true
      true
    }) do
      backup.stub(:upload, -> {
        upload_called = true
        true
      }) do
        assert backup.call
      end
    end

    assert dump_called
    assert upload_called
  end

  test "dump calls system with correct arguments" do
    backup = Backup::Db.new

    ENV["DB_NAME"] = "test_db"
    ENV["DB_USERNAME"] = "test_user"
    ENV["DB_PASSWORD"] = "test_password"
    ENV["DB_HOST"] = "localhost"

    expected_file = File.join(Rails.root, "tmp", "#{Date.today.strftime("%Y-%m-%d")}-test_db_test.backup")

    system_mock = Minitest::Mock.new
    system_mock.expect(:call, true, [{"PGPASSWORD" => "test_password"}, "/usr/bin/pg_dump", "--username=test_user", "--dbname=test_db", "--host=localhost", "--format=custom", "--file=#{expected_file}"])

    backup.stub(:system, system_mock) do
      backup.dump
    end

    assert_mock system_mock
  end

  test "upload calls GoogleDrive API" do
    backup = Backup::Db.new

    client_mock = Minitest::Mock.new
    client_mock.expect(:upload_file, true, [String])

    Backup::Db.class_eval do
      define_method(:google_drive_client) do
        client_mock
      end
    end

    backup.instance_variable_set(:@output_file, "dummy.backup")

    # we need to override the method locally for the test
    backup.method(:upload)

    backup.define_singleton_method(:upload) do
      Rails.logger.info "Uploading #{@output_file} to Google Drive"
      client = google_drive_client
      client.upload_file(@output_file)
    end

    backup.upload

    assert_mock client_mock
  end
end
