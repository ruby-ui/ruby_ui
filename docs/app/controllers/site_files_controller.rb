# frozen_string_literal: true

class SiteFilesController < ApplicationController
  def llms
    render plain: site_files.llms_txt, content_type: "text/plain; charset=utf-8"
  end

  def llms_full
    render plain: site_files.llms_full_txt, content_type: "text/plain; charset=utf-8"
  end

  def sitemap
    render plain: site_files.sitemap_xml, content_type: "application/xml; charset=utf-8"
  end

  private

  def site_files
    @site_files ||= SiteFiles.new
  end
end
