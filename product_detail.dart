import 'package:flutter/material.dart';
import 'cart_service.dart'; // Importa tu servicio de carrito

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String productId; 
  ProductDetail({required this.productData, required this.productId});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late int selectedQuantity;
  int maxQuantity = 10; // Ejemplo: máximo de 10 piezas disponibles

  @override
  void initState() {
    super.initState();
    selectedQuantity = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre: ${widget.productData['nombre']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Marca: ${widget.productData['marca']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Precio: \$${widget.productData['precio']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Descripción: ${widget.productData['descripcion']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cantidad:',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<int>(
                  value: selectedQuantity,
                  onChanged: (value) {
                    setState(() {
                      selectedQuantity = value!;
                    });
                  },
                  items: List.generate(maxQuantity, (index) => index + 1)
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addToCart,
              child: Text('Agregar al Carrito'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    // Verificar si productId no es nulo o vacío
    if (widget.productId.isNotEmpty) {
      // Llama al método addToCart del servicio de carrito para agregar el producto al carrito
      CartService().addToCart(widget.productData, selectedQuantity, widget.productId);
      
      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto agregado al carrito'),
        ),
      );
    } else {
      // Maneja el caso en que productId sea nulo o vacío (opcional)
      print('El ID del producto es nulo o vacío');
    }
  }
}
