module Admin
    class UsersController < Admin::ApplicationController
        before_action :authenticate_user!

        # To customize the behavior of this controller,
        # simply overwrite any of the RESTful actions. For example:
        #
        class VendorSearch < Administrate::Search
            def run(vendor_id)
                resource_class.where("(#{query}) and vendor_id = ?", *search_terms, vendor_id)
            end
        end

        def index
            # search bar data
            search_term = params[:search].to_s.strip

            # local, over-ridden class to include vendor id search
            resources = VendorSearch.new(resource_resolver, search_term).run(current_user.vendor_id)

            resources = order.apply(resources)
            resources = resources.page(params[:page]).per(records_per_page)
            page = Administrate::Page::Collection.new(dashboard, order: order)

            render locals: {
                resources: resources,
                search_term: search_term,
                page: page,
            }
        end

        def edit
            if requested_resource.vendor_id == current_user.vendor_id
                render locals: {
                    page: Administrate::Page::Form.new(dashboard, requested_resource),
                }
            else
                redirect_to :back, :alert => "Access denied."
            end
        end

        # Define a custom finder by overriding the `find_resource` method:
        #def find_resource(param)
        #User.find_by!(slug: param)
        #end

        # See https://administrate-docs.herokuapp.com/customizing_controller_actions
        # for more information
    end
end