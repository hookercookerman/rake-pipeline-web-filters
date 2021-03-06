require 'rake-pipeline-web-filters/filter_with_dependencies'

module Rake::Pipeline::Web::Filters
  # A filter that compiles input files written in SCSS
  # to CSS using the Sass compiler and the Compass CSS
  # framework.
  #
  # Requires {http://rubygems.org/gems/sass sass} and
  # {http://rubygems.org/gems/compass compass}
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.scss"
  #     output "public"
  #
  #     # Compile each SCSS file under the app/assets
  #     # directory.
  #     filter Rake::Pipeline::Web::Filters::SassFilter
  #   end
  class SassFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    # @return [Hash] a hash of options to pass to Sass
    #   when compiling.
    attr_reader :options

    # @param [Hash] options options to pass to the Sass
    #   compiler
    # @option options [Array] :additional_load_paths a
    #   list of paths to append to Sass's :load_path.
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options={}, &block)
      block ||= proc { |input| input.sub(/\.(scss|sass)$/, '.css') }
      super(&block)
      Compass.add_project_configuration
      @options = Compass.configuration.to_sass_engine_options
      @options[:load_paths].concat(Array(options.delete(:additional_load_paths)))
      @options.merge!(options)
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Compiles each input file with Sass.
    #
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      inputs.each do |input|
        sass_opts = if input.path.match(/\.sass$/)
          options.merge(:syntax => :sass)
        else
          options
        end
        output.write Sass.compile(input.read, sass_opts)
      end
    end

    private

    def external_dependencies
      [ 'sass', 'compass' ]
    end
  end
end
