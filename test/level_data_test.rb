# Not code testing, but rather testing the integrity of the level data files.

Dir["config/levels/*.yml"].each do |file|
  context "Checking '#{file}'" do
    setup { YAML::load_file(file) }

    asserts("same number of messages as screens") { topic['messages'].size == topic['floor']['tiles'].count("m") }

    context "floor" do
      setup { topic['floor'] }

      context "tiles" do
        setup { topic['tiles'].split("\n") }

        asserts("number of rows") { topic.size }.equals 5
      end

      context "default tile" do
        setup { Kernel.const_get(topic['default_tile']) }

        asserts("inherits from FloorTile") { topic.ancestors.include? FloorTile }
      end
    end

    context "wall" do
      setup { topic['wall'] }

      context "tiles" do
        setup { topic['tiles'].split("\n") }

        asserts("number of rows") { topic.size }.equals 3
      end

      context "default tile" do
        setup { topic['default_tile'] }

        asserts_topic.kind_of Array
        asserts_topic.size 2
      end
    end

    context 'all rows' do
      setup { (topic['wall']['tiles'].split("\n") + topic['floor']['tiles'].split("\n")) }

      asserts("rows of the same length") { topic.map {|row| row.length }.uniq.size == 1 }
    end
  end
end