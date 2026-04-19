# HostPartOrder: 10
#
# Define generated hosts entries in the $hosts array below.
# Each entry currently supports Action = 'add', a host Name, and an IP.
# Use config values like $config.ApacheIP when the entry should follow
# configured local IP/portproxy mappings.
# Blank Name values can be used for section headers or comments.

$hosts = @(
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '# WSL Virtual Hosts'}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## Web Roots'}
    [PSCustomObject]@{Action = 'add'; Name = 'apache.local'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'nginx.local'; IP = $config.NginxIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = ''}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## Resonance Designs'}
    [PSCustomObject]@{Action = 'add'; Name = 'official.resonancedesigns # Resonance Designs'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'maintenance.resonancedesigns # Resonance Designs: Maintenance'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'wordpress.resonancedesigns # Resonance Designs: WordPress'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'dev-labs.resonancedesigns # Resonance Designs: Development Labs'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'dev-labs.resonancedesigns.phpmyadmin # Resonance Designs: Development Labs - PHPMyAdmin'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'dev-labs.resonancedesigns.exercises # Resonance Designs: Development Labs - Exercises'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'dev-labs.resonancedesigns.tutorials # Resonance Designs: Development Labs - Tutorials'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'dev-labs.resonancedesigns.wordpress # Resonance Designs: Development Labs - WordPress'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'nginx.resonancedesigns # Resonance Designs: Nginx'; IP = $config.NginxIP}
    [PSCustomObject]@{Action = 'add'; Name = 'redmine.resonancedesigns # Resonance Designs: Redmine'; IP = $config.RailsIP}
    [PSCustomObject]@{Action = 'add'; Name = 'docman.resonancedesigns # Resonance Designs: DocMan'; IP = $config.MERNIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = ''}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = '## MMI Studios'}
    [PSCustomObject]@{Action = 'add'; Name = 'official.mmistudios # MMI Studios'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'maintenance.mmistudios # MMI Studios: Maintenance'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'wordpress.mmistudios # MMI Studios: WordPress'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'tlbx-1.mmistudios # MMI Studios: TLBX-1'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'mmibox.mmistudios # MMI Studios: MMIBox'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = 'animate.mmistudios # MMI Studios: Animate'; IP = $config.ApacheIP}
    [PSCustomObject]@{Action = 'add'; Name = ''; IP = ''}
)
