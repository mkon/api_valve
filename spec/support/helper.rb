module Helper
  def example_app(example)
    path = Pathname.new(__FILE__).join("../../../examples/#{example}/config.ru")
    Rack::Builder.parse_file(path.to_s)
  end
end
