#!/bin/bash

add_dns_entries() {
    ENTRIES=("3000.simple.local" "4000.simple.local")
    NEEDS_ADDING=()

    # Check which entries need to be added
    for ENTRY in "${ENTRIES[@]}"; do
        if ! grep -q "$ENTRY" /etc/hosts; then
            NEEDS_ADDING+=("$ENTRY")
        fi
    done

    if [ ${#NEEDS_ADDING[@]} -ne 0 ]; then
        osascript -e 'tell app "System Events" to display dialog "We need to add *.simple.local entries to /etc/hosts. This requires administrative privileges. Please approve the subsequent prompts to proceed." with title "DNS Setup" buttons {"Continue"} default button "Continue"'
        
        for ENTRY in "${NEEDS_ADDING[@]}"; do
            if ! osascript -e "do shell script \"echo '::1 $ENTRY' >> /etc/hosts\" with administrator privileges with prompt \"Adding entry for $ENTRY to /etc/hosts\""; then
                osascript -e "tell app \"System Events\" to display dialog \"There was a problem adding the entry for $ENTRY to /etc/hosts. Please check your permissions and try again.\" with title \"DNS Setup Error\" buttons {\"OK\"} default button \"OK\""
                exit 1
            fi

            if ! osascript -e "do shell script \"echo '127.0.0.1 $ENTRY' >> /etc/hosts\" with administrator privileges with prompt \"Adding entry for $ENTRY to /etc/hosts\""; then
                osascript -e "tell app \"System Events\" to display dialog \"There was a problem adding the entry for $ENTRY to /etc/hosts. Please check your permissions and try again.\" with title \"DNS Setup Error\" buttons {\"OK\"} default button \"OK\""
                exit 1
            fi
        done
        
        osascript -e 'tell app "System Events" to display dialog "All specified entries were successfully added to /etc/hosts." with title "DNS Setup Complete" buttons {"OK"} default button "OK"'
    fi
}

add_dns_entries
