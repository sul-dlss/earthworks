module EarthworksGeoblacklightHelper
  include GeoblacklightHelper
  def document_available?
    (@document.public? && @document.available?) || (@document.same_institution? && user_signed_in? && @document.available?)
  end
end
