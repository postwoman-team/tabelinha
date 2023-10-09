Gem::Specification.new do |s|
  s.name        = 'tabelinha'
  s.version     = '0.1.3'
  s.summary     = 'Customizable ASCII table generation'
  s.description = 'This gem generates tables from a array of rows, allowing options and tools ranging from what character the table is made of, to breaking lines if the requested table width is too small'
  s.authors     = ['Hikari Luz']
  s.email       = 'hikaridesuyoo@gmail.com'
  s.files       = ['lib/table.rb']
  s.files      += Dir["doc/**/*"]
  s.homepage    =
    'https://github.com/Hikari-desuyoo/tabelinha'
  s.license = 'GPL-2.0'
end
