import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductUploader extends StatefulWidget {
  @override
  _ProductUploaderState createState() => _ProductUploaderState();
}

class _ProductUploaderState extends State<ProductUploader> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _unidadesController = TextEditingController();
  final TextEditingController _presentacionController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subir Producto'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_nombreController, 'Nombre del Producto'),
            _buildTextField(_marcaController, 'Marca'),
            _buildTextField(_descripcionController, 'Descripción'),
            _buildTextField(_precioController, 'Precio', TextInputType.number),
            _buildTextField(_unidadesController, 'Unidades Disponibles', TextInputType.number),
            _buildTextField(_presentacionController, 'Presentación'),
            _buildTextField(_categoriaController, 'Categoría'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadProduct,
              child: Text('Subir Producto'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, [TextInputType? keyboardType]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: labelText),
    );
  }

  Future<void> _uploadProduct() async {
    try {
      final Map<String, dynamic> productData = {
        'nombre': _nombreController.text,
        'marca': _marcaController.text,
        'descripcion': _descripcionController.text,
        'precio': double.parse(_precioController.text),
        'unidades_disponibles': int.parse(_unidadesController.text),
        'presentacion': _presentacionController.text,
        'categoria': _categoriaController.text,
      };

      await _firestore.collection('productos').add(productData);
      _resetFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto subido correctamente.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir el producto: $error')),
      );
    }
  }

  void _resetFields() {
    _nombreController.clear();
    _marcaController.clear();
    _descripcionController.clear();
    _precioController.clear();
    _unidadesController.clear();
    _presentacionController.clear();
    _categoriaController.clear();
  }
}
