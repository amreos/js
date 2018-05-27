module EscapeRegexTerms

	def escape_term(term)
    term = Regexp.escape(term)
  end

  module_function :escape_term
end