# Docs::ComponentStruct = Struct.new(:name, :source, :language, :builder) do
#   def initialize(name:, source:, language: :phlex, builder: false)
#     super(name, source, language, builder)
#   end
# end

Docs::ComponentStruct = Struct.new(:name, :source, :builder, :built_using) do
  def initialize(name:, source:, builder: false, built_using: :phlex)
    super(name, source, builder, built_using)
  end
end