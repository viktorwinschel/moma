#!/bin/bash

# Exit on error
set -e

# Build the documentation
julia --project=docs/ docs/make.jl

# Save current changes to main
git add .
git commit -m "Update code and documentation, 5, todos"
git push origin main

# Create and switch to temporary branch
git checkout --orphan gh-pages-temp

# Remove everything except docs/build
git rm -rf .
cp -r docs/build/* .
rm -rf docs

# Add and commit documentation
git add .
git commit -m "Update documentation"

# Force push to gh-pages
git push -f origin gh-pages-temp:gh-pages

# Return to main and cleanup
git checkout main
git branch -D gh-pages-temp
git checkout main

# Build the documentation
julia --project=docs/ docs/make.jl

echo "Documentation updated successfully!"
