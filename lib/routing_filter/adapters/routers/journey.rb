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

    # Rails 8.1 rewrites path_info to the mount-relative path before yielding a
    # non-anchored (mounted) route; restoring it there would hand the engine the full path.
    result = super(req) do |route, parameters|
      params = (parameters || {}).merge(filter_parameters)
      req.path_info = original_path if route.path.anchored
      yield [route, params]
    end

    req.path_info = original_path
    result
  end
end

ActionDispatch::Journey::Router.prepend(ActionDispatchJourneyRouterWithFiltering)
