module Helper
  def example_app(example)
    path = Pathname.new(__FILE__).join("../../../examples/#{example}/config.ru")
    # In rack 2.x parse_file returns a tuple
    app, _config = *Rack::Builder.parse_file(path.to_s)
    app
  end
end
