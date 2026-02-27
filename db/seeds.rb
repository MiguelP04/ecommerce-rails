Faker::Config.locale = 'es'

puts "Limpiando base de datos..."
VariantOptionValue.destroy_all
OptionValue.destroy_all
Option.destroy_all
ProductVariant.destroy_all
Product.destroy_all
Category.destroy_all

puts "Creando categorias..."

categories = ["Electrónica", "Hogar", "Deportes", "Belleza", "Libros"].map do |c| 
    Category.create!(name: c, slug: c.parameterize)
end

puts "Creando Opciones y Valores..."
opt_color = Option.create!(name: "Color")
opt_size = Option.create!(name: "Talla")

colors = ["Rojo", "Azul", "Negro", "Blanco"].map { |c| OptionValue.create!(option: opt_color, name: c)}
sizes = ["S", "M", "L", "XL"].map { |t| OptionValue.create!(option: opt_size, name: t)}

puts "Creando 50 productos aleatorios..."
50.times do
    p_name = Faker::Commerce.product_name
    product = Product.create!(
        category: categories.sample,
        title: p_name,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        active: true,
        slug: "#{p_name.parameterize}-#{rand(1000.9999)}"
    )

    available_combinations = colors.product(sizes).shuffle

    3.times do |i|
        combo = available_combinations.pop
        selected_color = combo[0]
        selected_size = combo[1]

        variant_name = "#{selected_color.name} / #{selected_size.name}"

        variant = ProductVariant.create!(
            product: product,
            name: variant_name,
            sku: "#{Faker::Barcode.unique.ean}-#{i}",
            price: Faker::Commerce.price(range: 10..500.0),
            stock: rand(1..50)
        )

        VariantOptionValue.create!(product_variant: variant, option_value: selected_color)
        VariantOptionValue.create!(product_variant: variant, option_value: selected_size)
    end
end


puts "---"
puts "Seeds completados:" 
puts "- Opciones: #{Option.count} (Color y Talla)"
puts "- Valores de opción: #{OptionValue.count}"
puts "- Productos: #{Product.count}"
puts "- Variantes: #{ProductVariant.count}"
puts "- Vínculos variantes-opciones: #{VariantOptionValue.count}"

# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
