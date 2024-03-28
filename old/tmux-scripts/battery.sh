#1/bin/bash

echo `acpi | tail -n +2 | cut -d "," -f2`
