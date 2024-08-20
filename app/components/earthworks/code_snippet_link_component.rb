module Earthworks
  # Display link that triggers modal with code snippet content
  class CodeSnippetLinkComponent < ViewComponent::Base
    # Do not display the link to code snippets if the document is restricted
    def key
      'code_snippet_link'
    end
  end
end
