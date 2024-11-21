#Comprehensive script to identify installed OpenStack components based on installed packages, DNS records, and running processes.
#It lists each identified component along with its current service status and provides an option to save the report with the hostname and timestamp.



#!/bin/bash

# Function to fetch installed packages related to OpenStack
check_installed_packages() {
    echo "Checking for OpenStack components via installed packages..."
    dpkg -l | grep openstack | awk '{print $2}' | while read -r package; do
        echo "$package: $(systemctl is-active "$package" 2>/dev/null || echo 'not active')"
    done
}

# Function to identify OpenStack services via running processes
check_running_processes() {
    echo "Checking running processes for OpenStack components..."
    ps aux | grep -i "openstack" | grep -v grep | awk '{print $11}' | sort | uniq | while read -r process; do
        echo "$process: Running"
    done
}

# Function to check DNS records
check_dns_records() {
    echo "Checking DNS records for OpenStack components..."
    for service in keystone glance nova cinder neutron horizon; do
        if host "$service" >/dev/null 2>&1; then
            echo "$service DNS entry exists"
        else
            echo "$service DNS entry not found"
        fi
    done
}

# Function to save the report
save_report() {
    filename="openstack_components_$(hostname)_$(date '+%Y%m%d_%H%M%S').txt"
    echo "Saving the report as $filename..."
    echo "$1" > "$filename"
    echo "Report saved successfully!"
}

# Main script
echo "OpenStack Component Identification Script"
echo "----------------------------------------"

report=""

# Installed Packages Check
report+="\nInstalled Packages:\n"
installed_packages=$(check_installed_packages)
report+="$installed_packages\n"

# Running Processes Check
report+="\nRunning Processes:\n"
running_processes=$(check_running_processes)
report+="$running_processes\n"

# DNS Records Check
report+="\nDNS Records:\n"
dns_records=$(check_dns_records)
report+="$dns_records\n"

# Display report
echo -e "$report"

# Option to save report
read -p "Do you want to save this report to a file? (yes/no): " save_choice
if [[ "$save_choice" == "yes" ]]; then
    save_report "$report"
fi

echo "Script execution completed."
