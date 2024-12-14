import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartService {
  static const _keyCart = 'cart';

  final _cartUpdatedController = StreamController<Map<String, dynamic>>.broadcast();

  // Stream para escuchar los cambios en el carrito
  Stream<Map<String, dynamic>> get cartUpdatedStream => _cartUpdatedController.stream;

  // Método para obtener el carrito guardado
  Future<Map<String, dynamic>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_keyCart);
    if (cartString != null) {
      return json.decode(cartString);
    }
    return {};
  }

  // Método para agregar un producto al carrito
  Future<void> addToCart(Map<String, dynamic> product, int quantity, String productId) async {
    final cart = await getCart();
    cart[productId] = {'productData': product, 'quantity': quantity};
    await _saveCart(cart);
    _cartUpdatedController.add(cart);
  }

  // Método para eliminar un producto del carrito o reducir su cantidad
  Future<void> removeFromCart(String productId) async {
    final cart = await getCart();
    if (cart.containsKey(productId)) {
      final int currentQuantity = cart[productId]['quantity'];
      if (currentQuantity > 1) {
        // Si la cantidad actual es mayor que 1, simplemente reducimos la cantidad en uno
        cart[productId]['quantity'] = currentQuantity - 1;
      } else {
        // Si la cantidad actual es 1 o menos, eliminamos completamente el producto del carrito
        cart.remove(productId);
      }
      await _saveCart(cart);
      _cartUpdatedController.add(cart);
    }
  }

  // Método para guardar el carrito
  Future<void> _saveCart(Map<String, dynamic> cart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCart, json.encode(cart));
  }

  // Método para limpiar el carrito
  Future<void> clearCart() async {
    await _saveCart({});
    _cartUpdatedController.add({});
  }

  // Método para obtener detalles del carrito (productos, cantidad, precio)
  Future<Map<String, dynamic>> getCartDetails() async {
    final cart = await getCart();
    return cart;
  }

  // Cerrar el stream controller
  void dispose() {
    _cartUpdatedController.close();
  }
  Future<void> updateQuantity(String productId, int quantity) async {
  final cart = await getCart();
  if (cart.containsKey(productId)) {
    cart[productId]['quantity'] = quantity;
    await _saveCart(cart);
    _cartUpdatedController.add(cart);
  }
}
}
