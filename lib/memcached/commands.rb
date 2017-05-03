module Commands
  STORAGE_COMMANDS = %w(set add replace append prepend cas).freeze
  RETRIEVAL_COMMANDS = %w(get gets).freeze
end
