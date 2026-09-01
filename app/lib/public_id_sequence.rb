module PublicIdSequence
  module_function

  def next_value(prefix, year, connection)
    seq = "public_id_#{prefix.downcase}_#{year}"
    connection.select_value(%(SELECT nextval('#{seq}'))).to_i
  rescue ActiveRecord::StatementInvalid => e
    raise unless e.cause.is_a?(PG::UndefinedTable)
    connection.execute(%(CREATE SEQUENCE IF NOT EXISTS "#{seq}"))
    retry
  end
end