
# Exit on error
set -e

# Stash any changes
git stash

# Ensure we're on main branch
git checkout main

# Build the documentation
julia --project=docs/ docs/make.jl
git add .
git commit -m "Update local documentation $(date +%Y-%m-%d)"
git push origin main

# Create temp directory for docs
TEMP_DOCS_DIR=$(mktemp -d)
cp -r docs/build/* "$TEMP_DOCS_DIR/"

# Switch to gh-pages branch (create if doesn't exist)
if git show-ref --verify --quiet refs/heads/gh-pages; then
    git checkout gh-pages
    git pull origin gh-pages
    git rm -rf .
else
    git checkout --orphan gh-pages
    git rm -rf .
fi

# Copy documentation from temp directory
cp -r "$TEMP_DOCS_DIR"/* .

# Add and commit
git add .
git commit -m "Update documentation $(date +%Y-%m-%d)"

# Push to gh-pages
git push -f origin gh-pages

# Cleanup
rm -rf "$TEMP_DOCS_DIR"
please run update_docs.sh and 
# Return to main and restore changes
git checkout main
git stash pop || true

echo "Documentation updated successfully!"
