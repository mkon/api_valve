module ApiValve
  module Benchmarking
    def benchmark
      result = nil
      time = Benchmark.realtime do
        result = yield
      end
      [result, time]
    end
  end
end
