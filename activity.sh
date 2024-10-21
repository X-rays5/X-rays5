#!/bin/bash

# Fetch the latest activity of the GitHub account
curl -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/users/X-rays5/events > events.json

# Exclude activity from specific repositories and private repositories
jq '[.[] | select(.repo.name | test("^(?!GTAV_decompiled_scripts|xenforo|volkstuin|patriciasnc).*$")) | select(.public == true)] | .[:10]' events.json > filtered_events.json

# Format the activity data to include type, link, date/time, and repository name
latest_activity=$(jq -r '.[] | "* \(.type) in [\(.repo.name)](\(.repo.url)) on \(.created_at | strftime("%Y-%m-%d %H:%M:%S"))"' filtered_events.json)

# Ensure the activity list is ordered in reverse chronological order
latest_activity=$(echo "$latest_activity" | sort -r)

# Group similar activities together and display as a single entry with a summary
grouped_activity=$(echo "$latest_activity" | awk '{a[$2]++;} END {for (i in a) print a[i], i;}')

# Update the README.md file with the latest activity
sed -i '/<!-- LATEST_ACTIVITY_START -->/!b;n;c\<!-- LATEST_ACTIVITY_START -->\n'"$grouped_activity"'\n<!-- LATEST_ACTIVITY_END -->' README.md
