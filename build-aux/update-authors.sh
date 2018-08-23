#!/bin/bash

# Written in 2017, 2018 by Mohammed Sadiq <sadiq@sadiqpk.org>

# To the extent possible under law, the author(s) have dedicated all
# copyright and related and neighboring rights to this software to
# the public domain worldwide.  This software is distributed without
# any warranty.

# You should have received a copy of the CC0 Public Domain Dedication
# along with this software.  If not, see
# <http://creativecommons.org/publicdomain/zero/1.0/>.

# This script requires GNU Bash 4+.
# Get the authors list sorted by commit count, shuffle/add more,
# Then sort it again numberwise, and remove the preceding numbers.
# Then create an AUTHORS files in project root directory.

# If you have to correct some names, like fixing typos, you can use
# .mailmap files.  Please see the manpage of 'git shortlog' for more.

typeset -A MORE_AUTHORS
declare -a DELETE_AUTHORS

# Translation directories.  The directories where the .po files
# are saved, related to the project root, separated by space.
TRANS_DIR="po"

# Add list of extra names you wish to credit as Authors.  You can add
# names that haven't had any commit to the repository, but you wish to give
# credits.  Escape regex characters, if any.
MORE_AUTHORS=(
  # [Full Name]=Commit count
  [New Name]=7
)

# Names to be deleted. Escape regex characters, if any
DELETE_AUTHORS=("Bad Name" "Another Bad Name")

olddir="$(pwd)"

# Go up one level if required
if [ ! -d ".git" ]; then
  cd ..
fi
topdir="$(pwd)"

# Add git exclusion rule to every given path
TRANS_DIR=":(exclude)${TRANS_DIR// / :(exclude)}"

# Get the authors list from git
AUTHORS="$(git shortlog --no-merges -sn --pretty=format:"%an" -- . $TRANS_DIR 2>/dev/null)"

if [ ! "${AUTHORS}" ]; then
  echo "Author list empty. Make sure \"$topdir\" is a git repo directory"
  exit 1
fi

# Delete names
for name in "${DELETE_AUTHORS[@]}"; do
  AUTHORS="$(sed "/^[0-9 \t]*$name\$/d" <<< "$AUTHORS")"
done

# Delete blank lines
AUTHORS="$(sed '/^\s*$/d' <<< "$AUTHORS")"

# Add further authors and commit count
for name in "${!MORE_AUTHORS[@]}"; do
  count="${MORE_AUTHORS[$name]}"
  AUTHORS="${AUTHORS}"$'\n'"$count $name"
done

# Sort numerically and remove the preceding numbers
AUTHORS="$(sort -sgbr <<< "$AUTHORS" | sed 's/^[0-9 \t]*//')"

if [ ! "${AUTHORS}" ]; then
  echo "Author list empty. Not updating"
  exit 1
fi

# Actually update AUTHORS file
echo "# Autogenerated. Do NOT update manually." > "${topdir}/AUTHORS"
echo "# Sorted with descending order of number of commits" >> "${topdir}/AUTHORS"
echo "" >> "${topdir}/AUTHORS"
echo "$AUTHORS" >> "${topdir}/AUTHORS"

echo "AUTHORS file updated"
