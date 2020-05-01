#!/bin/bash
#
# Update things to be compatible with Molecule 3.0.
#
# This script is NOT idempotent, and should never be run again.
exit 1

export LINT_STRING="lint: |
  set -e
  yamllint .
  ansible-lint"

# Loop through all directories starting with "geerlingguy".
for dir in ./geerlingguy*/
do
  # cd into role directory.
  cd "$dir"

  # Change string `pip install molecule` to `pip install molecule yamllint ansible-lint` in .travis.yml
  sed -i '' 's/pip install molecule docker/pip install molecule yamllint ansible-lint docker/g' .travis.yml

  # Change and remove strings in molecule.yml
  sed -i '' '/[ ][ ]name: yamllint/d' molecule/default/molecule.yml
  sed -i '' '/[ ][ ]options:/d' molecule/default/molecule.yml
  sed -i '' '/[ ][ ][ ][ ]config-file:.*/d' molecule/default/molecule.yml
  sed -i '' 's/-playbook.yml/-converge.yml/g' molecule/default/molecule.yml
  sed -i '' '/[ ][ ]lint:/d' molecule/default/molecule.yml
  sed -i '' '/[ ][ ][ ][ ]name: ansible-lint/d' molecule/default/molecule.yml
  sed -i '' '/verifier:/d' molecule/default/molecule.yml
  sed -i '' '/[ ][ ]name: testinfra/d' molecule/default/molecule.yml
  sed -i '' '/[ ][ ][ ][ ]name: flake8/d' molecule/default/molecule.yml

  # Update lint block in molecule.yml file.
  perl -i -pe 's/lint:/$ENV{"LINT_STRING"}/g' molecule/default/molecule.yml

  # Move file `molecule/default/yaml-lint.yml` to `.yamllint` (if exists).
  if [ -f molecule/default/yaml-lint.yml ]; then
     mv molecule/default/yaml-lint.yml .yamllint
  fi

  # Move file `molecule/default/playbook.yml` to `molecule/default/converge.yml` (if exists).
  if [ -f molecule/default/playbook.yml ]; then
     mv molecule/default/playbook.yml molecule/default/converge.yml
  fi

  # cd back to parent directory.
  cd ..
done