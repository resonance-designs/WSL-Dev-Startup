# HostPartOrder: 10

$hosts = @(
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '# WSL Virtual Hosts'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## Web Roots'}
    [PSCustomObject]@{Action = 'add'; Name = 'localwsl.apache.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'localwsl.nginx.local'; IP = $config.NginxIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My LAMP Apps'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Resonance Designs'}
    [PSCustomObject]@{Action = 'add'; Name = 'official.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'maintenance.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'wordpress.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'wpdev.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'nm-business.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Resonance Designs: Development Labs'}
    [PSCustomObject]@{Action = 'add'; Name = 'dev-labs.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'phpmyadmin.dev-labs.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'exercises.dev-labs.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'tuts-and-examples.dev-labs.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'wordpress.dev-labs.resonancedesigns.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My Nginx Apps'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Resonance Designs'}
    [PSCustomObject]@{Action = 'add'; Name = 'nginx.dev-labs.resonancedesigns.local'; IP = $config.NginxIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My Rails Apps'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Redmine'}
    [PSCustomObject]@{Action = 'add'; Name = 'redmine.rails.local'; IP = $config.RailsIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My MERN Apps'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Doc-Man'}
    [PSCustomObject]@{Action = 'add'; Name = 'doc-man.mern.local'; IP = $config.MERNIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = ''}
)
