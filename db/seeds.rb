Faker::Config.locale = 'es'

puts "Limpiando base de datos..."
Product.destroy_all
Category.destroy_all

puts "Creando categorias..."

categorias = ["Electrónica", "Hogar", "Deportes",       "Belleza", "Libros"].map do|nombre| 
    Category.create!(name: nombre, slug: nombre.parameterize)
end

puts "Creando 50 productos aleatorios..."
50.times do
    product_name = Faker::Commerce.product_name
    product = Product.create!(
        category: categorias.sample,
        title: product_name,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        active: true,
        slug: "#{product_name.parameterize}-#{rand(1000.9999)}",
        metadata: {
            brand: Faker::Company.name,
            material: Faker::Commerce.material
        }
    )

    ["Small", "Medium", "Large"].sample(rand(2..3)).each do |option|
        ProductVariant.create!(
            product: product,
            name: option,
            sku: Faker::Barcode.unique.ean13,
            price: Faker::Commerce.price(range: 10..2000.0),
            stock: rand(1..100)
        )
    end
end


puts "---"
puts "Seeds terminados con éxito:" 
puts "- Categorías: #{Category.count}"
puts "- Productos: #{Product.count}"
puts "- Variantes totales: #{ProductVariant.count}"

    

# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
