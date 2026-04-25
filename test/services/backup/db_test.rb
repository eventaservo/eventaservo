require "test_helper"

class BackupDbTest < ActiveSupport::TestCase
  test "calls dump and upload" do
    backup = Backup::Db.new
    dump_called = false
    upload_called = false

    # Because methods might not be defined for mocking, we just redefine them for the instance
    backup.define_singleton_method(:dump) do
      dump_called = true
      true
    end

    backup.define_singleton_method(:upload) do
      upload_called = true
      true
    end

    assert backup.call

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

    system_called = false
    passed_args = []

    backup.define_singleton_method(:system) do |*args|
      system_called = true
      passed_args = args
      true
    end

    backup.dump

    assert system_called
    assert_equal [
      {"PGPASSWORD" => "test_password"},
      "/usr/bin/pg_dump",
      "--username=test_user",
      "--dbname=test_db",
      "--host=localhost",
      "--format=custom",
      "--file=#{expected_file}"
    ], passed_args
  end

  test "upload calls GoogleDrive API" do
    backup = Backup::Db.new

    client_mock = Minitest::Mock.new
    client_mock.expect(:upload_file, true, [String])

    google_drive_mock = Minitest::Mock.new
    google_drive_mock.expect(:new, client_mock)

    original_google_drive = Object.const_defined?(:GoogleDrive) ? Object.const_get(:GoogleDrive) : nil
    Object.send(:remove_const, :GoogleDrive) if original_google_drive

    begin
      Object.const_set(:GoogleDrive, Module.new { const_set(:Client, google_drive_mock) })

      backup.instance_variable_set(:@output_file, "dummy.backup")
      backup.upload

      assert_mock client_mock
      assert_mock google_drive_mock
    ensure
      Object.send(:remove_const, :GoogleDrive)
      Object.const_set(:GoogleDrive, original_google_drive) if original_google_drive
    end
  end
end
