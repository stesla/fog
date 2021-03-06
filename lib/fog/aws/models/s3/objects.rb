module Fog
  module AWS
    class S3

      class Objects < Fog::Collection

        attribute :delimiter,     'Delimiter'
        attribute :is_truncated,  'IsTruncated'
        attribute :marker,        'Marker'
        attribute :max_keys,      'MaxKeys'
        attribute :prefix,        'Prefix'

        model Fog::AWS::S3::Object

        def all(options = {})
          collection = bucket.collection.get(
            bucket.name,
            options.reject {|key, value| !['delimiter', 'marker', 'max-keys', 'prefix'].include?(key)}
          )
          collection && collection.objects
        end

        def bucket
          @bucket
        end

        def get(key, options = {}, &block)
          options = {
            'delimiter'   => @delimiter,
            'marker'      => @marker,
            'max-keys'    => @max_keys,
            'prefix'      => @prefix
          }.merge!(options)
          data = connection.get_object(bucket.name, key, options, &block)
          object_data = {
            :body => data.body,
            :key  => key
          }
          for key, value in data.headers
            if ['Content-Length', 'Content-Type', 'ETag', 'Last-Modified'].include?(key)
              object_data[key] = value
            end
          end
          object = Fog::AWS::S3::Object.new({
            :bucket     => bucket,
            :collection => self,
            :connection => connection
          }.merge!(object_data))
          object
        rescue Excon::Errors::NotFound
          nil
        end

        def get_url(key, expires)
          connection.get_object_url(bucket.name, key, expires)
        end

        def head(key, options = {})
          data = connection.head_object(bucket.name, key, options)
          object_data = {
            :key => key
          }
          for key, value in data.headers
            if ['Content-Length', 'Content-Type', 'ETag', 'Last-Modified'].include?(key)
              object_data[key] = value
            end
          end
          object = Fog::AWS::S3::Object.new({
            :bucket     => bucket,
            :collection => self,
            :connection => connection
          }.merge!(object_data))
          object
        rescue Excon::Errors::NotFound
          nil
        end

        def new(attributes = {})
          super({ :bucket => bucket }.merge!(attributes))
        end

        private

        def bucket=(new_bucket)
          @bucket = new_bucket
        end

      end

    end
  end
end
