namespace :public_ids do
  desc "Backfill public_id (slow, resumable, low-impact)"
  task backfill: :environment do
    batch_size = Integer(ENV.fetch("BATCH_SIZE", 500))
    pause      = Float(ENV.fetch("SLEEP_SECONDS", 0.25))
    prefix = "C"
    model = CaseReport
    backfill_model(prefix, model, batch_size, pause)
  end
  def backfill_model(prefix, model, batch_size, pause)
    total = model.where(public_id: nil).count
    return if total.zero?
    server = Rails.application.config.x.server_abbreviation
    min_year = model.where(public_id: nil).minimum(:created_at)&.year
    return if min_year.nil?
    done = 0
    busy = 0.0
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    (min_year..Time.current.year).each do |year|
      range = Time.zone.local(year)...Time.zone.local(year + 1)
      model.where(public_id: nil, created_at: range).in_batches(of: batch_size) do |batch|
        batch_started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        ids = batch.pluck(:id)
        whens = ids.map do |id|
          number = SixDigitCipherHelper.scramble(PublicIdSequence.next_value(prefix, year, model.connection))
          public_id = "#{prefix}-#{server}-#{year}-#{format('%06d', number)}"
          "WHEN #{model.connection.quote(id)} THEN #{model.connection.quote(public_id)}"
        end
        batch.update_all(Arel.sql("public_id = CASE id #{whens.join(' ')} END"))
        busy += Process.clock_gettime(Process::CLOCK_MONOTONIC) - batch_started
        done += ids.size
        puts "[#{model.name}] #{done}/#{total}"
        sleep(pause)
      end
    end
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    rate = busy.positive? ? done / busy : 0
    puts format("[%s] done %d in %.2fs total, %.2fs busy (%.0f rec/s excl. sleep)",
                model.name, done, elapsed, busy, rate)
  end
end