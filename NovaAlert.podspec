Pod::Spec.new do |spec|
    spec.name           = 'NovaAlert'
    spec.version        = '0.1'
    spec.license        = { :type => 'MIT', :file => "LICENSE" }
    spec.homepage       = 'https://github.com/netizen01/NovaAlert'
    spec.authors        = { 'Netizen01' => 'n01@invco.de' }
    spec.summary        = 'Another Alert Package. Because.'
    spec.source         = { :git => 'https://github.com/netizen01/NovaAlert.git',
                            :tag => spec.version.to_s }
    spec.source_files   = 'Source/**/*.swift'
    
    spec.dependency     'NovaCore', '~> 0.1'
    spec.dependency     'Cartography', '~> 0.6'

    spec.ios.deployment_target  = '8.4'
end
