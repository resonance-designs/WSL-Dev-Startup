# Give WSL Apache a static IP on port 80
netsh interface portproxy add v4tov4 listenport=80 listenaddress=$apache_ip connectport=$apache_port connectaddress=$wsl_ip

# Give WSL Nginx a static IP on port 81
netsh interface portproxy add v4tov4 listenport=80 listenaddress=$nginx_ip connectport=$nginx_port connectaddress=$wsl_ip