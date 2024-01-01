[PSCustomObject]@{Action = 'add'; Name = ''; IP = '# WSL Virtual Hosts'}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '## Web Roots'}
[PSCustomObject]@{Action = 'add'; Name = 'localwsl.apache'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = 'localwsl.nginx'; IP = $nginx_ip}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My LAMP Apps'}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Resonance Designs'}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.official'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.maintenance'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.wordpress'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.nm-business'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Resonance Designs: Development Labs'}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.phpmyadmin'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.exercises'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.tuts-and-examples'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.wordpress'; IP = $apache_ip}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My Nginx Apps'}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Resonance Designs'}
[PSCustomObject]@{Action = 'add'; Name = 'resonance-designs.dev-labs.nginx'; IP = $nginx_ip}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My Rails Apps'}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Redmine'}
[PSCustomObject]@{Action = 'add'; Name = 'rails.redmine'; IP = $rails_ip}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '## My MERN Apps'}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = '### Doc-Man'}
[PSCustomObject]@{Action = 'add'; Name = 'mern.doc-man'; IP = $mern_ip}
[PSCustomObject]@{Action = 'add'; Name = ''; IP = ''}