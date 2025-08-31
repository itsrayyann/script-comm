start_date="2025-06-11"
end_date="2025-07-31"
file="README.md"

current_date="$start_date"
week_start=""
days_committed_this_week=0
max_commit_days_per_week=0

while [[ "$current_date" < "$end_date" || "$current_date" == "$end_date" ]]; do
    current_week_start=$(gdate -I -d "$current_date - $(gdate -d "$current_date" +%u) days + 1 day")
    
    if [[ "$week_start" != "$current_week_start" ]]; then
        week_start="$current_week_start"
        days_committed_this_week=0
        max_commit_days_per_week=$((3 + RANDOM % 2))
    fi
    
    should_commit=false
    if [[ $days_committed_this_week -lt $max_commit_days_per_week ]]; then
        day_of_week=$(gdate -d "$current_date" +%u)
        remaining_days_in_week=$((8 - day_of_week))
        remaining_commit_days=$((max_commit_days_per_week - days_committed_this_week))
        
        if [[ $remaining_days_in_week -le $remaining_commit_days ]]; then
            should_commit=true
        else
            chance=$((RANDOM % remaining_days_in_week))
            if [[ $chance -lt $remaining_commit_days ]]; then
                should_commit=true
            fi
        fi
    fi
    
    if [[ "$should_commit" == "true" ]]; then
        commits=$((1 + RANDOM % 5))
        days_committed_this_week=$((days_committed_this_week + 1))
        
        for ((i=1; i<=commits; i++)); do
            hour=$((9 + RANDOM % 9))
            minute=$((RANDOM % 60))
            second=$((RANDOM % 60))

            commit_time=$(printf "%02d:%02d:%02d" $hour $minute $second)
            echo "$current_date commit $i at $commit_time" >> $file

            export GIT_AUTHOR_DATE="${current_date}T${commit_time}+00:00"
            export GIT_COMMITTER_DATE="${current_date}T${commit_time}+00:00"
            
            git add $file
            git commit -m "Commit $i for $current_date at $commit_time"
        done
        
        echo "✅ $current_date: $commits commits (Day $days_committed_this_week/$max_commit_days_per_week this week)"
    else
        echo "⭕ $current_date: No commits (Day $days_committed_this_week/$max_commit_days_per_week this week)"
    fi
    
    current_date=$(gdate -I -d "$current_date + 1 day")
done

git push origin main
echo "Done! Pushed all commits to GitHub."