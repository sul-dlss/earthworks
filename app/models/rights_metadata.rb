class RightsMetadata
  def initialize(rights_metadata)
    @rights_metadata = rights_metadata
  end

  def use_and_reproduction
    ng_xml.xpath('//rightsMetadata/use/human[@type="useAndReproduction"]').first.try(:content)
  end

  def copyright
    ng_xml.xpath('//rightsMetadata/copyright').first.try(:content)
  end

  def license
    @license ||= License.new(url: license_url)
  end

  def license?
    license_url.present?
  end

  private

  def ng_xml
    @ng_xml ||= Nokogiri::XML(@rights_metadata)
  end

  # Try each way, from most prefered to least preferred to get the license
  def license_url
    license_url_from_node || url_from_attribute || url_from_code
  end

  # This is the most modern way of determining what license to use.
  def license_url_from_node
    ng_xml.at_xpath('//rightsMetadata/use/license').try(:text).presence
  end

  # This is a slightly older way, but it can differentiate between CC 3.0 and 4.0 licenses
  def url_from_attribute
    return unless machine_node

    machine_node['uri'].presence
  end

  # This is the most legacy and least preferred way, because it only handles out of data license versions
  def url_from_code
    type, code = machine_readable_license
    return unless type && code.present?

    case type.to_s
    when 'creativeCommons'
      if code == 'pdm'
        'https://creativecommons.org/publicdomain/mark/1.0/'
      else
        "https://creativecommons.org/licenses/#{code}/3.0/legalcode"
      end
    when 'openDataCommons'
      case code
      when 'odc-pddl', 'pddl'
        'https://opendatacommons.org/licenses/pddl/1-0/'
      when 'odc-by'
        'https://opendatacommons.org/licenses/by/1-0/'
      when 'odc-odbl'
        'https://opendatacommons.org/licenses/odbl/1-0/'
      end
    end
  end

  def machine_readable_license
    [machine_node.attribute('type'), machine_node.text] if machine_node
  end

  def machine_node
    @machine_node ||= ng_xml.at_xpath('//rightsMetadata/use/machine[@type="openDataCommons" or @type="creativeCommons"]')
  end
end
