Pod::Spec.new do |spec|

    spec.name                   = 'NovaAlert'
    spec.version                = '0.8'
    spec.summary                = 'Another Alert Package. Because.'

    spec.homepage               = 'https://github.com/netizen01/NovaAlert'
    spec.license                = { :type => 'MIT', :file => 'LICENSE' }
    spec.author                 = { 'Netizen01' => 'n01@invco.de' }

    spec.ios.deployment_target  = '9.3'

    spec.source                 = { :git => 'https://github.com/netizen01/NovaAlert.git',
                                    :tag => spec.version.to_s }
    spec.source_files           = 'Source/**/*.swift'
    spec.swift_versions         = ['5.0']
    
    spec.dependency             'NovaCore'
    spec.dependency             'Cartography'

end
