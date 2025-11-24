module RoutingFilter
  class Chain < Array
    def <<(filter)
      filter.previous, last.next = last, filter if last
      super
    end
    alias push <<

    def unshift(filter)
      filter.next, first.previous = first, filter if first
      super
    end

    def run(method, *args, &final)
      active? ? first.run(method, *args, &final) : final.call
    end

    def active?
      RoutingFilter.active? && !empty?
    end

    def excluded?(path)
      any? do |filter|
        if filter.respond_to?(:exclude) && filter.exclude
          case filter.exclude
          when Regexp
            path =~ filter.exclude
          when Proc
            filter.exclude.call(path)
          else
            false
          end
        elsif filter.respond_to?(:excluded?, true)
          filter.excluded?(path)
        else
          false
        end
      end
    end
  end
end
