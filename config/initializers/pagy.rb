# frozen_string_literal: true

# Pagy::DEFAULT is frozen, so we replace it with a new hash that includes our overrides.
Pagy::DEFAULT = Pagy::DEFAULT.merge(limit: 30).freeze
