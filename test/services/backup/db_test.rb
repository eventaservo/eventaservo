require "test_helper"

class BackupDbTest < ActiveSupport::TestCase
  test "calls dump and upload" do
    backup = Backup::Db.new
    dump_called = false
    upload_called = false

    backup.define_singleton_method(:dump) { |*|
      dump_called = true
      true
    }
    backup.define_singleton_method(:upload) { |*|
      upload_called = true
      true
    }

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

    system_called = false
    passed_args = []

    backup.define_singleton_method(:system) do |*args|
      system_called = true
      passed_args = args
      true
    end

    backup.send(:dump, "/tmp/test_dump.backup")

    assert system_called
    assert_equal [
      {"PGPASSWORD" => "test_password"},
      "/usr/bin/pg_dump",
      "--username=test_user",
      "--dbname=test_db",
      "--host=localhost",
      "--format=custom",
      "--file=/tmp/test_dump.backup"
    ], passed_args
  end

  test "upload calls GoogleDrive API" do
    backup = Backup::Db.new

    client_mock = Minitest::Mock.new
    client_mock.expect(:upload_file, true, [String, String])

    google_drive_mock = Minitest::Mock.new
    google_drive_mock.expect(:new, client_mock)

    original_google_drive = Object.const_defined?(:GoogleDrive) ? Object.const_get(:GoogleDrive) : nil
    Object.send(:remove_const, :GoogleDrive) if original_google_drive

    begin
      Object.const_set(:GoogleDrive, Module.new { const_set(:Client, google_drive_mock) })

      backup.send(:upload, "dummy.backup", "test.backup")

      assert_mock client_mock
      assert_mock google_drive_mock
    ensure
      Object.send(:remove_const, :GoogleDrive)
      Object.const_set(:GoogleDrive, original_google_drive) if original_google_drive
    end
  end
end
