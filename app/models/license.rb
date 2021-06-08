class License # rubocop:disable Metrics/ClassLength
  attr_reader :url, :label, :css_class, :image

  def initialize(url:)
    attrs = LICENSES.fetch(url)
    @url = url
    @label = attrs.fetch(:label)
    @css_class = attrs.fetch(:css_class, nil)
    @image = attrs.fetch(:image, nil)
  end

  def description
    return 'This work is in the public domain per Creative Commons Public Domain Mark 1.0' if public_domain?

    "This work is licensed under a #{label}"
  end

  def public_domain?
    url == 'http://creativecommons.org/publicdomain/mark/1.0/'
  end

  alias link url

  LICENSES = {
    'https://www.gnu.org/licenses/agpl.txt' => {
      label: 'AGPL-3.0-only GNU Affero General Public License'
    },
    'https://www.apache.org/licenses/LICENSE-2.0' => {
      label: 'Apache-2.0'
    },
    'https://opensource.org/licenses/BSD-2-Clause' => {
      label: 'BSD-2-Clause "Simplified" License'
    },
    'https://opensource.org/licenses/BSD-3-Clause' => {
      label: 'BSD-3-Clause "New" or "Revised" License'
    },
    'https://creativecommons.org/licenses/by/4.0/legalcode' => {
      css_class: 'earthworks-license-by',
      image: 'by.png',
      label: 'CC-BY-4.0 Attribution International'
    },
    'https://creativecommons.org/licenses/by-nc/4.0/legalcode' => {
      css_class: 'earthworks-license-by-nc',
      image: 'by-nc.png',
      label: 'CC-BY-NC-4.0 Attribution-NonCommercial International'
    },
    'https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode' => {
      css_class: 'earthworks-license-by-nc-nd',
      image: 'by-nc-nd.png',
      label: 'CC-BY-NC-ND-4.0 Attribution-NonCommercial-No Derivatives'
    },
    'https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode' => {
      css_class: 'earthworks-license-by-nc-sa',
      image: 'by-nc-sa.png',
      label: 'CC-BY-NC-SA-4.0 Attribution-NonCommercial-Share Alike International'
    },
    'https://creativecommons.org/licenses/by-nd/4.0/legalcode' => {
      css_class: 'earthworks-license-by-nd',
      image: 'by-nd.png',
      label: 'CC-BY-ND-4.0 Attribution-No Derivatives International'
    },
    'https://creativecommons.org/licenses/by-sa/4.0/legalcode' => {
      css_class: 'earthworks-license-by-sa',
      image: 'by-sa.png',
      label: 'CC-BY-SA-4.0 Attribution-Share Alike International'
    },
    'https://creativecommons.org/publicdomain/zero/1.0/legalcode' => {
      css_class: 'earthworks-license-pdm',
      image: 'pdm.png',
      label: 'CC0 - 1.0'
    },
    'https://opensource.org/licenses/cddl1' => {
      label: 'CDDL-1.1 Common Development and Distribution License'
    },
    'https://www.eclipse.org/legal/epl-2.0' => {
      label: 'EPL-2.0 Eclipse Public License'
    },
    'https://www.gnu.org/licenses/gpl-3.0-standalone.html' => {
      label: 'GPL-3.0-only GNU General Public License'
    },
    'https://www.isc.org/downloads/software-support-policy/isc-license/' => {
      label: 'ISC License'
    },
    'https://www.gnu.org/licenses/lgpl-3.0-standalone.html' => {
      label: 'LGPL-3.0-only Lesser GNU Public License'
    },
    'https://opensource.org/licenses/MIT' => {
      label: 'MIT License'
    },
    'https://www.mozilla.org/MPL/2.0/' => {
      label: 'MPL-2.0 Mozilla Public License'
    },
    'https://opendatacommons.org/licenses/by/1-0/' => {
      label: 'ODC-By-1.0 Attribution License'
    },
    'http://opendatacommons.org/licenses/odbl/1.0/' => {
      # This is a non-canonical url found in some existing data. It redirects to
      # https://opendatacommons.org/licenses/odbl/1-0/
      label: 'ODbL-1.0 Open Database License'
    },
    'https://opendatacommons.org/licenses/odbl/1-0/' => {
      label: 'ODbL-1.0 Open Database License'
    },
    'https://creativecommons.org/publicdomain/mark/1.0/' => {
      css_class: 'earthworks-license-pdm',
      image: 'pdm.png',
      label: 'Creative Commons Public Domain Mark 1.0'
    },
    'https://opendatacommons.org/licenses/pddl/1-0/' => {
      css_class: 'earthworks-license-pdm',
      image: 'pdm.png',
      label: 'Open Data Commons Public Domain Dedication and License (PDDL-1.0)'
    },
    'https://creativecommons.org/licenses/by/3.0/legalcode' => {
      css_class: 'earthworks-license-by',
      image: 'by.png',
      label: 'Creative Commons Attribution 3.0 Unported License'
    },
    'https://creativecommons.org/licenses/by-sa/3.0/legalcode' => {
      css_class: 'earthworks-license-by-sa',
      image: 'by-sa.png',
      label: 'Creative Commons Attribution Share Alike 3.0 Unported License'
    },
    'https://creativecommons.org/licenses/by-nd/3.0/legalcode' => {
      css_class: 'earthworks-license-by-nd',
      image: 'by-nd.png',
      label: 'Creative Commons Attribution No Derivatives 3.0 Unported License'
    },
    'https://creativecommons.org/licenses/by-nc/3.0/legalcode' => {
      css_class: 'earthworks-license-by-nc',
      image: 'by-nc.png',
      label: 'Creative Commons Attribution-Noncommercial 3.0 Unported License'
    },
    'https://creativecommons.org/licenses/by-nc-sa/3.0/legalcode' => {
      css_class: 'earthworks-license-by-nc-sa',
      image: 'by-nc-sa.png',
      label: 'Creative Commons Attribution-Noncommercial-Share Alike 3.0 Unported License'
    },
    'https://creativecommons.org/licenses/by-nc-nd/3.0/legalcode' => {
      css_class: 'earthworks-license-by-nc-nd',
      image: 'by-nc-nd.png',
      label: 'Creative Commons Attribution-Noncommercial-No Derivative Works 3.0 Unported License'
    }
  }.freeze
end
