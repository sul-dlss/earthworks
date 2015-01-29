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
    cc_license || odc_licence
  end

  def ng_xml
    @ng_xml ||= Nokogiri::XML(@rights_metadata)
  end

  private

  def cc_license
    { human: cc_license_human, machine: cc_license_machine } if cc_license_human.present? && cc_license_machine.present?
  end

  def cc_license_machine
    ng_xml.xpath('//rightsMetadata/use/machine[@type="creativeCommons"]').first.try(:content)
  end

  def cc_license_human
    ng_xml.xpath('//rightsMetadata/use/human[@type="creativeCommons"]').first.try(:content)
  end

  def odc_licence
    { human: odc_licence_human, machine: odc_licence_machine } if odc_licence_human.present? && odc_licence_machine.present?
  end

  def odc_licence_human
    ng_xml.xpath('//rightsMetadata/use/human[@type="openDataCommons"]').first.try(:content)
  end

  def odc_licence_machine
    ng_xml.xpath('//rightsMetadata/use/machine[@type="openDataCommons"]').first.try(:content)
  end
end
