# frozen_string_literal: true

# To be shared with all classes that need database connection
module Database
  module_function

  # @return [Sequel]
  def db
    @db ||=
      Sequel.connect(
        adapter: 'postgres',
        host: 'localhost',
        database: ENV['DATABASE_NAME'],
        user: ENV['DATABASE_USER'],
        password: ENV['DATABASE_PASSWORD']
      )
  end
end
