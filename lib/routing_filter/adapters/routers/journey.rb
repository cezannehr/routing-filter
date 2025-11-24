module ActionDispatchJourneyRouterWithFiltering
  # NOTE: `find_routes` was inlined as `recognize` in Rails 8.1+
  def recognize(req, &block)
    path = req.path_info

    if @routes.respond_to?(:filters) && @routes.filters&.excluded?(path)
      return super(req, &block)
    end

    filter_parameters = {}
    original_path = path.dup

    @routes.filters.run(:around_recognize, path, req.env) do
      filter_parameters
    end

    super(req) do |route, parameters|
      params = (parameters || {}).merge(filter_parameters)
      req.path_info = original_path
      yield [route, params]
    end
  end
end

ActionDispatch::Journey::Router.prepend(ActionDispatchJourneyRouterWithFiltering)
