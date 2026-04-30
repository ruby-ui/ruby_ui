# frozen_string_literal: true

module Docs
  class DataTableDemoController < ApplicationController
    layout -> { Views::Layouts::ExamplesLayout }

    def index
      employees = DataTableDemoData::EMPLOYEES.dup

      if params[:search].present?
        q = params[:search].downcase
        employees = employees.select { |e| e.name.downcase.include?(q) || e.email.downcase.include?(q) }
      end

      if params[:sort].present?
        col = params[:sort].to_sym
        if employees.first&.respond_to?(col)
          employees = employees.sort_by do |e|
            v = e.send(col)
            v.is_a?(Numeric) ? v : v.to_s.downcase
          end
          employees = employees.reverse if params[:direction] == "desc"
        end
      end

      @total_count = employees.size
      @per_page = (params[:per_page] || 5).to_i.clamp(1, 100)
      @total_pages = [(@total_count.to_f / @per_page).ceil, 1].max
      @page = (params[:page] || 1).to_i.clamp(1, @total_pages)

      offset = (@page - 1) * @per_page
      @employees = employees.slice(offset, @per_page) || []

      render Views::Docs::DataTableDemo::Index.new(
        employees: @employees,
        total_count: @total_count,
        page: @page,
        per_page: @per_page,
        sort: params[:sort],
        direction: params[:direction],
        search: params[:search]
      )
    end

    def bulk_delete
      ids = Array(params[:ids]).map(&:to_s)
      flash[:notice] = "Would delete: #{ids.join(", ")}"
      redirect_to docs_data_table_demo_path
    end

    def bulk_export
      ids = Array(params[:ids]).map(&:to_s)
      flash[:notice] = "Would export: #{ids.join(", ")}"
      redirect_to docs_data_table_demo_path
    end
  end
end
