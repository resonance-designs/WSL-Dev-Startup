function StartWSLServices() {
    # Start Apache Service
    wsl -d "Ubuntu-22.04" sudo service apache2 restart
    # Start MySQL Service
    wsl -d "Ubuntu-22.04" sudo service mysql restart
}
