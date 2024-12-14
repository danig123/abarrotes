import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_uploader.dart';
import 'product_detail.dart';
import 'mostrar_carrito.dart';
import 'mostrar_ventas.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<String> categorias = [];
  String? categoriaSeleccionada;
  bool _showButtons = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    obtenerCategorias();
  }

  Future<void> obtenerCategorias() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('productos').get();
    Set<String> categoriasSet = Set();
    querySnapshot.docs.forEach((doc) {
      categoriasSet.add((doc.data() as Map<String, dynamic>)['categoria'] as String? ?? '');
    });
    setState(() {
      categorias = categoriasSet.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Lista de Productos'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        actions: [
          if (_showButtons)
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MostrarCarrito())),
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Opciones'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            buildListTile('Agregar un Producto', () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductUploader()))),
            buildListTile('Ver Carrito', () => Navigator.push(context, MaterialPageRoute(builder: (context) => MostrarCarrito()))),
            buildListTile('Ver Ventas Registradas', () => Navigator.push(context, MaterialPageRoute(builder: (context) => MostrarVentas()))),
          ],
        ),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: categoriaSeleccionada,
            hint: Text('Seleccionar categoría'),
            onChanged: (String? newValue) {
              setState(() {
                categoriaSeleccionada = newValue;
              });
            },
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Todas las categorías'),
              ),
              ...categorias.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              )),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('productos').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error al cargar los productos');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var document = snapshot.data!.docs[index];
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    if (categoriaSeleccionada == null || categoriaSeleccionada == data['categoria']) {
                      return ListTile(
                        title: Text('${data['nombre']}'),
                        subtitle: Text('Marca: ${data['marca']}'),
                        trailing: Text('\$${data['precio']}'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetail(
                              productData: data,
                              productId: document.id,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile buildListTile(String title, Function() onTap) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }
}
