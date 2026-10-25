$hookInput = [Console]::In.ReadToEnd()
try {
    $hookEvent = $hookInput | ConvertFrom-Json -ErrorAction Stop
} catch {
    [Console]::Error.WriteLine("Review hook failed to parse its event input: $($_.Exception.Message)")
    exit 1
}

if ($hookEvent.stop_hook_active -eq $true) {
    '{"decision":"allow"}'
    exit 0
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine("Review hook skipped: Git is unavailable.")
    '{}'
    exit 0
}

& git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("Review hook skipped: current directory is not a Git work tree.")
    '{}'
    exit 0
}

$changes = @(& git status --porcelain --untracked-files=all 2>&1)
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("Review hook failed to inspect Git changes: $($changes -join ' ')")
    exit 1
}

if ($changes.Count -eq 0) {
    '{"decision":"allow"}'
    exit 0
}

@{
    decision = "block"
    reason = "Review the changed files against .github/copilot-instructions.md and applicable project conventions. Then run /security-review on the staged and unstaged changes. Fix confirmed issues with minimal changes, or report findings and any checks not run. After that review, finish with a concise summary."
} | ConvertTo-Json -Compress
