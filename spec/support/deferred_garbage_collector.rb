# frozen_string_literal: true

#
# = DeferredGarbageCollector
#
#   See: https://www.devroom.io/2011/09/24/rspec-speed-up-by-tweaking-ruby-garbage-collection/
#
class DeferredGarbageCollector

  DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 20.0).to_f.freeze

  @@last_gc_run = Time.zone.now

  def self.start
    GC.disable if DEFERRED_GC_THRESHOLD > 0
  end

  def self.reconsider
    if DEFERRED_GC_THRESHOLD > 0 && Time.zone.now - @@last_gc_run >= DEFERRED_GC_THRESHOLD
      GC.enable
      GC.start
      GC.disable
      @@last_gc_run = Time.zone.now
    end
  end

end
