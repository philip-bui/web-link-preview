Pod::Spec.new do |s|
  s.name = 'WebLinkPreview'
  s.version = '1.0.0'
  s.license= { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Web Link Preview.'
  s.description = 'Create website link previews, given a web link.'
  s.homepage = 'https://github.com/philip-bui/web-link-preview'
  s.author = { 'Philip Bui' => 'philip.bui.developer@gmail.com' }
  s.source = { :git => 'https://github.com/philip-bui/web-link-preview.git', :tag => s.version }
  s.documentation_url = 'https://github.com/philip-bui/web-link-preview'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Sources/**/*.swift' 
  s.swift_version = '4.2'
end
