require "action_dispatch/routing/inspector"

class PagesController < ApplicationController
  def home

    @routes =
      Rails.application.routes.routes.map do |route|
        wrapper = ActionDispatch::Routing::RouteWrapper.new(route)
        next if skip_route?(wrapper)

        verb = wrapper.verb&.gsub(/\s/, "")
        path = wrapper.path.to_s.sub(/\(\.:format\)/, "")
        controller = wrapper.defaults[:controller]
        action = wrapper.defaults[:action]
        placeholders = path.scan(/[:\*]([a-zA-Z0-9_]+)/).flatten
        linkable = verb&.include?("GET") && path.present?
        direct_link = linkable && placeholders.empty?

        next if verb.blank? || path.blank? || controller.blank? || action.blank?

        {
          name: wrapper.name,
          verb: verb,
          path: path,
          controller: controller,
          action: action,
          link: direct_link ? path : nil,
          placeholders: placeholders
        }
      end.compact.uniq { |r| [r[:verb], r[:path]] }.sort_by { |r| [r[:path], r[:verb]] }

    @debug_info = {
      logged_in: logged_in?,
      user_role: current_user&.role.presence,
      user_email: current_user&.email
    }

    render layout: false
  end

  private

  def skip_route?(wrapper)
    controller = wrapper.defaults[:controller]
    return true if wrapper.internal? || controller.nil?
    return true if controller.start_with?("rails/", "action_mailbox/", "active_storage/")

    path = wrapper.path.to_s
    path.start_with?("/rails/")
  end
end
