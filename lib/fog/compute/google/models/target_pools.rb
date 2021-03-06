module Fog
  module Compute
    class Google
      class TargetPools < Fog::Collection
        model Fog::Compute::Google::TargetPool

        def all(region: nil, filter: nil, max_results: nil, order_by: nil, page_token: nil)
          opts = {
            :filter => filter,
            :max_results => max_results,
            :order_by => order_by,
            :page_token => page_token
          }
          if region.nil?
            data = []
            service.list_aggregated_target_pools(opts).items.each_value do |lst|
              unless lst.nil? || lst.target_pools.nil?
                data += lst.to_h[:target_pools]
              end
            end
          else
            data = service.list_target_pools(region, opts).to_h[:items]
          end
          load(data)
        end

        def get(identity, region = nil)
          if region
            target_pool = service.get_target_pool(identity, region).to_h
            return new(target_pool)
          elsif identity
            response = all(:filter => "name eq #{identity}")
            target_pool = response.first unless response.empty?
            return target_pool
          end
        rescue ::Google::Apis::ClientError => e
          raise e unless e.status_code = 404
          nil
        end
      end
    end
  end
end
