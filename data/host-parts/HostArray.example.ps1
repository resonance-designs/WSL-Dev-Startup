$hosts = @(
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '# WSL Virtual Hosts'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## Web Roots'}
    [PSCustomObject]@{Action = 'add'; Name = 'localwsl.apache'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'localwsl.nginx'; IP = $config.NginxIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My LAMP Apps'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Resonance Designs'}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.official'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.maintenance'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.wordpress'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.nm-business'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Resonance Designs: Development Labs'}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.phpmyadmin'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.exercises'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.tuts-and-examples'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.wordpress'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My Nginx Apps'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Resonance Designs'}
    [PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.nginx'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My Rails Apps'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Redmine'}
    [PSCustomObject]@{Action = 'add'; Name = 'rails.redmine'; IP = $config.RailsIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My MERN Apps'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Doc-Man'}
    [PSCustomObject]@{Action = 'add'; Name = 'mern.doc-man'; IP = $config.MERNIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = ''}
)