# frozen_string_literal: true

module Netomox
  module DiffView
    # aliases for hash key
    K_DS = '_diff_state_'
    K_DD = 'diff_data'
    K_FWD = 'forward'
    K_BWD = 'backward'
    K_PAIR = 'pair'
    # head mark
    H_ADD = '+' # added
    H_DEL = '-' # deleted
    H_CHG_S = '~' # changed_strict
    H_CHG = '.' # changed
  end
end
